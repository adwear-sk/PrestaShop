# Incident runbook — www.adwear.sk

What to do when production breaks. Every command runs **on the VPS as `deploy`, in `/opt/adwear`**
unless a card says otherwise. Start with `diagnose.sh`; each line it marks `!!` names one card below.

This file is copied to `/opt/adwear/RUNBOOK.md` on every deploy, and it is readable on GitHub from a
phone when the server is unreachable. Rollback and restore details live in [README.md § Day-to-day](README.md#day-to-day).
Never paste `.env` contents or the admin folder name anywhere (chat, issues, the board): this repo is public.

## 0. How you notice today

No alert leaves the server yet. `healthcheck.sh` runs every 5 minutes, but with `ALERT_URL` unset its
alerts only reach `logs/cron-healthcheck.log`. Push alerts come with the owner app (board items `ops-alerts`,
`app-alert-rules`). Until then, problems surface in one of three ways:

- **Daily morning check (the routine):** run `diagnose.sh` once a day. It takes about a minute.
- A customer or the employee reports it. The employee has a read-only back office and no SSH access, so they only
  tell the owner *what* they saw, *where* (the URL) and *when*.
- You notice it yourself.

```
ssh adwear /opt/adwear/diagnose.sh
```

`adwear` is an alias in your `~/.ssh/config` (`Host adwear` / `HostName <VPS IP>` / `User deploy`). Exit code
0 means all green. Re-run it after every fix: the fix is done when the `!!` lines are gone.

| `diagnose.sh` says | Card |
|---|---|
| a container not running, admin folder not readable | [Containers down](#containers-down) |
| homepage/category not 200, high load, MySQL connections or long queries, many `?q=` requests | [Site down or slow](#site-down-or-slow) |
| back office login not 200 while the shop is 200 | [Back office 500, shop works](#back-office-500-shop-works) |
| disk ≥ 85 % | [Disk full](#disk-full) |
| a sync/marker too old, `adwear:malfini` / `adwear:anda` has no commands | [Sync stale](#sync-stale) |
| `max_execution_time` not 120000, updates wait for a reboot | [After a reboot](#after-a-reboot) |
| no recent DB dump, or data is gone | [Data loss](#data-loss) |
| category page `/1002-vetrovky` 404 | [Pages 404](#pages-404) |
| it started right after a deploy | [Bad deploy](#bad-deploy) |

Every card follows the same order: **check → fix → verify → aftercare.** Aftercare always ends the same way:
write on the board what happened and what fixed it (a note on the related item, or a new finding), so the
next failure of the same kind is quicker to recognise.

---

## Site down or slow

Past cases: 2026-11-10 (3.5 h, scraper walking filter combinations on the home category, every MySQL connection busy)
and 2026-11-04 (see [Disk full](#disk-full)).

**Check:**
- `diagnose.sh` → MySQL connections, long queries, the crawler section (top IPs on `?q=`), load.
- The disk is under 100 %; if it isn't, go to [Disk full](#disk-full) first.
- Did it start right after a deploy? Then go to [Bad deploy](#bad-deploy).

**Fix (a MySQL backlog), in this order:**
1. If one or a few IPs dominate the crawler list, block them at Caddy. Open the Caddyfile in an editor
   (`nano Caddyfile`). It is a single-file bind mount, so don't use `sed -i`, which swaps the file and Caddy keeps
   reading the old one. Inside `www.adwear.sk {`, right after `encode zstd gzip`, add:
   ```
   @blocked remote_ip 203.0.113.7 198.51.100.0/24
   respond @blocked 403
   ```
   Then reload Caddy, which takes no downtime: `docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile`.
   A rotating botnet won't show up as a few IPs; the per-IP rate limit on `?q=` already covers that case, so skip
   to step 2.
2. Kill the stuck shop queries **and** restart Apache. Killing alone doesn't help: PrestaShop reconnects and starts
   the next slow query.
   ```
   docker compose exec -T mysql sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot -N -B -e "SELECT CONCAT(\"KILL \", id, \";\") FROM information_schema.processlist WHERE command = \"Query\" AND time > 20 AND user <> \"root\"" | mysql -uroot'
   docker compose exec app apache2ctl -k restart
   ```

**Fix (no MySQL backlog, still slow):** `docker stats --no-stream` shows what eats the CPU. A Malfini or Anda sync
holds the CPU for minutes at :30 and :05 past the hour; that's normal and passes. Anything else: `docker compose logs --tail 100 app`.

**Verify:** `diagnose.sh`: connections low, no long queries, homepage 200.

**Aftercare:** copy every IP block you added into `deploy/Caddyfile` in the repo, because the deploy does not sync the
Caddyfile. Note on the board what the requests looked like (path, user agent).

## Disk full

Past case: 2026-11-04 (13 h down). Crawlers filled the filter cache table `ps_layered_filter_block` and the binlogs,
and MySQL stopped committing.

**Check:** `df -h /`. Then find what is big:
```
docker system df
du -sh /opt/adwear/backups /opt/adwear/logs
docker compose exec mysql sh -c 'du -sh /var/lib/mysql/binlog.* 2>/dev/null | tail -3; du -sh /var/lib/mysql/*/ | sort -h | tail -3'
```
`diagnose.sh` lists the three largest tables, if MySQL still answers.

**Fix, least destructive first:**
1. **If MySQL is stuck at 100 %:** lower the ext4 root reserve. That frees about 3 GB instantly and deletes nothing.
   It needs root. At 100 % use the **Hetzner console** (see [Root access](#root-access-without-sudo)): the Docker route
   may not start a container on a full disk. Check the device with `findmnt -no SOURCE /` (it was `/dev/sda1`), then
   run `tune2fs -m 1 /dev/sda1` as root.
2. Empty the filter cache. It is pure cache, and the module itself purges it the same way. This works only once
   commits flow again (step 1):
   ```
   docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot "$MYSQL_DATABASE" -e "TRUNCATE ps_layered_filter_block"'
   ```
3. Old binlogs (normally kept 3 days):
   `docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "PURGE BINARY LOGS BEFORE NOW() - INTERVAL 1 DAY"'`
4. Dangling Docker images: `docker image prune -f`. This removes only untagged images; `release.sh` keeps the current
   and previous release.
5. Last resort: delete the oldest local dumps in `backups/`, but keep at least the two newest.

**Verify:** `df -h /` below 85 %, `diagnose.sh` green, an order or cart write works.

**Aftercare:** give the root reserve back once there's room again. As root: `tune2fs -r 808307 /dev/sda1`, which was the
original value. If crawlers caused it, also work through [Site down or slow](#site-down-or-slow).

## Sync stale

Past case: from 2026-10-24, the syncs failed for 10 days with the site at 200. MySQL had restarted, and the app
container was compiled while the database was down, **without any module**.

**Check:**
- `diagnose.sh` names the stale marker and shows whether `adwear:malfini` / `adwear:anda` have commands.
- The cron log of the job: `tail -n 30 logs/cron-stock.log` (or `cron-products`, `cron-prices`, `cron-anda-stock`,
  `cron-anda-products`, `cron-catalog-apply`, `cron-prune-history`).

**Fix: "no commands" (container compiled without modules).** Check `diagnose.sh` first: MySQL must answer. Then:
```
docker compose exec -T -u www-data app sh -c 'rm -rf var/cache/* ; php -d memory_limit=-1 bin/console cache:clear --env=prod'
docker compose exec -T -u www-data app php bin/console list adwear:malfini --env=prod | grep -c 'adwear:malfini:'
docker compose restart app
```
Under traffic the `rm` can report "Directory not empty". It has still done its job, so check the count before you run
it again. The restart makes sure no Apache worker keeps the old container.

**Fix: the job itself fails** (an error in its log):
- Malfini returns all zeros between 23:00 and 23:59 UTC. That's why the stock sync skips that slot, and a single
  failed run there is harmless.
- The Anda feeds answer only this server's IP. A 403 in `cron-anda-*.log` means Anda blocked or changed something.
  Contact them.
- To run a job by hand, paste its crontab line from `deploy/crontab` (keep the `flock`: it refuses to start while
  the cron run holds the lock, so two syncs never write at once), for example:
  ```
  flock -n /tmp/malfini-stock.lock docker compose exec -T -u www-data app php -d memory_limit=-1 bin/console adwear:malfini:sync-stock >> logs/cron-stock.log 2>&1 && touch logs/.ok-sync-stock
  ```

**Verify:** the marker is fresh again (manual run or the next cron run); the `diagnose.sh` line turns `ok`.

## Back office 500, shop works

Past case: 2026-10-03, the back office was down for 4 days and nobody noticed. The front office and the back office
compile separate containers.

**Check:** the healthcheck log (`tail -n 20 logs/cron-healthcheck.log | sed -E 's#/admin[^ /]*#/ADMIN#g'`).
On a failure it records whether the compiled container named in the error is MISSING or EXISTS on disk.

**Fix:**
- MISSING (workers pinned to a deleted container): `docker compose restart app`.
- EXISTS (the container is incomplete): run the cache rebuild and restart from [Sync stale](#sync-stale).
- `healthcheck.sh` can do the restart by itself (`AUTO_RESTART=1` on its line in `deploy/crontab` in the repo; the live
  crontab is overwritten by every deploy). It is off by default.

**Verify:** `diagnose.sh` → back office login 200.

## Containers down

**Check:** `docker compose ps -a` and `docker compose logs --tail 50 <service>`.

**Fix:**
- `mysql`: `docker compose up -d mysql`. Data lives in a named volume. After MySQL comes back,
  check [Sync stale](#sync-stale), because the app may have compiled without modules.
- `caddy`: `docker compose up -d --no-deps --no-build caddy`. Without `--no-deps` compose may recreate `app` too;
  without `--no-build` a missing image starts a Caddy build on the VPS, which fails there.
- `app` stopped (exited): `docker compose start app`. That keeps the container as it is.
- `app` missing, or it keeps crashing: re-release the image that is supposed to be live:
  ```
  ./release.sh "$(sed -n 's/^APP_IMAGE=//p' .env | tail -1)"
  ```
  **Never** run a bare `docker compose up -d` for `app`. A recreate loses `.htaccess` and `robots.txt` (see
  [Pages 404](#pages-404)), and `release.sh` is what puts them back.

**Verify:** `diagnose.sh` green.

## Pages 404

Past case: 2026-08-09, two weeks of 404s. A manual recreate of the app container lost `.htaccess`, so friendly URLs stopped working.

**Check:** the homepage works, but `/1002-vetrovky` or product pages return 404:
`docker compose exec app test -f .htaccess && echo present || echo MISSING`.

**Fix:** re-release the live image (the command in [Containers down](#containers-down)). It regenerates `.htaccess`,
`robots.txt`, translations, mails and the cache.

**Verify:** `diagnose.sh` → `/1002-vetrovky 200`.

## Bad deploy

**Main app (core, theme in the image):** `./release.sh rollback` returns to the previous image, which is still on
disk, and runs every post-step. Run it again to come back. Older releases: `./release.sh list`. A rollback does not
undo `deploy/sql` migrations or the newer crontab and host scripts. Details: [README.md § Day-to-day](README.md#day-to-day).

**A module:** `git revert` in the module repo and push `main`. Never edit files on the server. See the README Day-to-day row.

**Verify:** `diagnose.sh` green, then reproduce what was broken.

## After a reboot

A reboot or a MySQL restart is the moment the app can compile without modules: the app container doesn't wait for MySQL.

**How to reboot:** in a quiet window, outside 02:15–06:00 UTC (imports, backup, prunes) and away from :05 and :30
past the hour (stock syncs). Use the Hetzner console (*Power → Restart*), or as root `systemctl reboot` (see
[Root access](#root-access-without-sudo)).

**After it:** `diagnose.sh`. If `adwear:malfini` has no commands, do the fix in [Sync stale](#sync-stale).
`max_execution_time` should read 120000; it is persisted, and `release.sh` sets it again on every release. If it
doesn't, set it by hand:
```
docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SET PERSIST max_execution_time = 120000"'
```

## Root access without sudo

Nobody on the box has `sudo`. Root works two ways:

- **Docker** (the `deploy` user is in the `docker` group, which amounts to root):
  ```
  docker run --rm --privileged --pid=host ubuntu:24.04 nsenter -t 1 -m -u -n -i <command>
  ```
  It needs the `ubuntu:24.04` image on the box (`docker image ls ubuntu`; pull it once while all is well:
  `docker pull ubuntu:24.04`). On a 100 % full disk Docker may fail to start a container. Then use the console.
- **Hetzner Cloud console** → the server → *Console* (a browser terminal, works without SSH and without network
  inside the VM). If you don't know the root password, *Rescue → Reset root password*. Login details are in Bitwarden.

## Data loss

Wrong data or lost data, for example a bad migration or a deleted table.

**Stop first.** Don't restore over live orders without thinking it through: every order since the dump would be lost.
Take a fresh dump before anything else: `./backup.sh`. Then decide what to restore.

- Restore a nightly local dump (`backups/db-<stamp>.sql.gz`, kept for several days):
  ```
  gunzip < backups/db-<stamp>.sql.gz | docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot "$MYSQL_DATABASE"'
  ```
- Off-site copies and the full disaster-recovery procedure (server lost) are board item `ops-backups-offsite`,
  step s60 (a timed restore drill), which lands in README.md. Until it does, Hetzner Cloud Backups of the server
  (if enabled in the console) are the off-site fallback.

**Verify:** the shop shows recent products and orders; `diagnose.sh` green.

---

*Keeping this true:* when a change to `deploy/` scripts, the crontab, the Caddyfile or the compose file changes how a
failure looks or is fixed, update its card in the same commit. Each new kind of outage gets a card.
