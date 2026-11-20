---
name: adwear-copy-db-rehearsal
description: >
  Rehearse a data-changing run (catalog apply, supplier import, attribute merge) on a private copy of the shared DB
  from a worktree, prove the 2nd run changes 0, then restore every shared file it touched.
  Trigger: "rehearse on a copy DB", "dry run for real", "test the import without touching the shared DB".
argument-hint: "<worktree-name e.g. wt2>"
allowed-tools: Bash, Read, Write, Edit
produces: prestashop_<wtN> copy DB, baseline + restore files in .ai/work/<wtN>/, pass/fail numbers for the step's verified field
---

# Copy-DB rehearsal

Worktrees share the main DB **and** the `img`, `upload`, `download` folders (`bin/worktree.sh` mounts them from the
main checkout). Assignees must not change shared-DB state ([WORKFLOW §2](../../WORKFLOW.md#2-locate-the-owning-repo)),
so anything that writes products, categories, attributes or config runs on a copy. The DB copy is private; **the
image folders are not**: every file the run writes lands in the main checkout and must be removed afterwards.

`<wt>` below = the worktree name (`wt2`), `W` = `/home/kciariot/AdwearPresta-<wt>`,
`A` = `/home/kciariot/AdwearPresta/.ai/work/<wt>` (gitignored, survives WSL restarts).

## 1. Create or refresh the copy (~1 min)

```bash
docker exec adwearpresta-mysql-1 sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; db=prestashop_<wt>;
  mysql -uroot -e "DROP DATABASE IF EXISTS $db; CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci" &&
  mysqldump -uroot --single-transaction --no-tablespaces --default-character-set=utf8mb4 prestashop |
  mysql -uroot --default-character-set=utf8mb4 $db' 2>&1 | grep -v Warning
```

- Only ever `DROP` a `prestashop_wt*` database. Refresh before each rehearsal whose numbers matter (the shared DB
  moves: syncs, main's integrations).
- No domain changes needed: the worktree's request-host hack serves `http://<wt>.localhost:80N1` from any DB.
- Query helper for the copy (scratchpad):
  `docker exec -i adwearpresta-mysql-1 sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot prestashop_<wt> --table --default-character-set=utf8mb4'`

## 2. Point the worktree at the copy

```bash
[ -f $A/parameters.shared-db.php ] || cp $W/app/config/parameters.php $A/parameters.shared-db.php
sed -i "s/'database_name' => 'prestashop'/'database_name' => 'prestashop_<wt>'/" $W/app/config/parameters.php
docker compose -f $W/docker-compose.worktree.yml exec -T -u www-data prestashop-git php bin/console cache:clear
```

Log it in `$A/progress.md` right away ("wt on copy DB — restore before READY"): a session that dies here leaves the
worktree silently on the copy. Module installs/upgrades needed by the rehearsal run on the copy only.

## 3. Baseline the shared files — before the first write

```bash
S=/home/kciariot/AdwearPresta/img
docker exec adwearpresta-mysql-1 sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot -N -e "SELECT MAX(id_image) FROM prestashop.ps_image; SELECT MAX(id_attribute) FROM prestashop.ps_attribute"'
cp $S/co/catalog-swatches.json $A/<item>-catalog-swatches.restore.json   # if the run can generate swatches
cp -a $S/co $A/<item>-co-backup                                            # small; lets you undo overwrites
touch $A/<item>-baseline.stamp
```

Write the baseline numbers into the progress log. What lands where:

| Writer | Shared path | Named by |
|--------|-------------|----------|
| Product images (supplier syncs) | `img/p/<digits of id_image>/` | `ps_image.id_image` (copy continues the shared sequence) |
| Colour swatches + manifest (catalog apply) | `img/co/<id_attribute>.jpg`, `img/co/catalog-swatches.json` | `ps_attribute.id_attribute` |
| Category / menu images | `img/c/<id_category>*.jpg` | `ps_category.id_category` |
| Attachments, uploads | `download/`, `upload/` | random names |

Run product syncs with images only on a small pilot (`--codes`/`--limit`); measure MB per image there and do the
full run `--no-images`.

## 4. Rehearse and measure

1. Run the real commands (same flags as the planned cron/rollout).
2. **Pass criterion: run it again — the 2nd run changes 0** (sync log / ApplyReport / `Changed: 0`). Anything
   else is a bug, not noise.
3. Record per run: duration, created/updated/failed, visibility live/hidden, disk per image. These go into the
   step's `verified` field and the rollout plan.
4. Screenshots on `http://<wt>.localhost:80N1` (`adwear-verify-storefront`); friendly URLs, not
   `index.php?id_…` (debug redirect page).

The worktree may stay on the copy for the user's click-through at the checkpoint — say so in the report.

## 5. Restore — before READY TO INTEGRATE

List what the run created, then delete exactly that:

```bash
find $S/co $S/c -newer $A/<item>-baseline.stamp -type f > $A/<item>-img-created.txt
```

1. **Check the shared DB first:** `MAX(id_image)` on `prestashop` must still equal the baseline. If main or a cron
   created images meanwhile, the ids overlap — stop and sort it out before deleting.
2. Delete `img/p` leaf dirs for the rehearsal's id range only (baseline+1 … copy's `MAX(id_image)`):
   ```bash
   for id in $(seq <first> <last>); do d=$S/p/$(echo $id | sed 's/./&\//g'); d=${d%/}
     [ -d "$d" ] && [ -z "$(find "$d" -mindepth 1 -type d)" ] && rm -rf "$d"; done   # sub-dirs = longer ids: keep
   ```
3. Delete the listed `img/co` / `img/c` files, but only ids above the shared max (`id_attribute` > shared max etc.);
   copy the manifest back from the `.restore.json`.
4. `cp $A/parameters.shared-db.php $W/app/config/parameters.php`, `cache:clear`, home page 200.
5. `git -C <repo> status` clean in the worktree and every nested repo.
6. Note "shared state restored" in the progress log and the item note. Leave `prestashop_<wt>` in place (a
   private copy costs nothing and the next rehearsal refreshes it); main may drop it.

## Pitfalls

- A `--force` sync or a re-run after the restore writes images again — repeat §5.
- `catalog apply` on the copy rewrites `img/co/catalog-swatches.json` even when it only adds a few colours: always
  back up the manifest (§3). If a listed `img/co`/`img/c` file has an id the shared DB also uses, it was
  overwritten, not created — copy it back from `$A/<item>-co-backup`, never just delete it.
- The first apply after a big import changes more than the dry run predicted (visibility, colour families); only the
  2nd run's 0 counts.
