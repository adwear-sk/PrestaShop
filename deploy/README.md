# Production deployment — www.adwear.sk

A push-to-deploy setup for a single PrestaShop store on a Hetzner VPS.

## How it works

```
  GitHub (adwear-sk)                    GitHub Actions                 Hetzner VPS (/opt/adwear)
  ──────────────────                    ──────────────                 ─────────────────────────
  PrestaShop (fork)   ─push production→  composer + asset build  ─GHCR→  app  ← Caddy (auto-TLS) ← :443
                                          → Docker image → GHCR    ─ssh→  release.sh <image>:<sha>
  category-migrator   ─push main──────→  rsync ─────────────────────────→ custom/modules/category_migrator
  malfini-api         ─push main──────→  composer + rsync ─────────────→  custom/modules/malfini_api
  (custom theme repo) ─push main──────→  npm build + rsync ────────────→  custom/themes/adwear
```

- The **fork** is heavy to build (Composer + Node assets), so CI bakes it into a versioned Docker image. The VPS only ever *pulls* it — it never runs Composer or Node.
- **Custom modules + theme** are gitignored in the fork, so they deploy separately into bind-mounted folders. They don't trigger an image rebuild.
- **Customer data** (`img/ upload/ download/ var/ mails/`) and the install config live in named Docker volumes — untouched by deploys.

## Files in this folder

| File | Role |
|------|------|
| `Dockerfile` | Builds the production app image (CI only) |
| `docker-compose.yml` | The VPS stack: caddy + app + mysql |
| `Caddyfile` | Auto-HTTPS for www.adwear.sk, access log, filter rate limits |
| `caddy/Dockerfile` | Caddy + the rate_limit plugin (built locally, loaded onto the VPS) |
| `php-prod.ini` | Production PHP/OPcache tuning |
| `.env.prod.example` | Template for the server's secrets file |
| `provision.sh` | One-time VPS hardening + Docker install |
| `backup.sh` | Nightly verified DB dump + encrypted off-site borg backup of DB, volumes and `/opt/adwear` (cron 03:15) |
| `borgmatic/config.yaml` | What the off-site backup holds, retention 7d/4w/6m, checks |

---

## One-time setup

### 1. Create the VPS
Hetzner Cloud → Ubuntu 24.04, CX22 or larger. Note the IP.

### 2. Provision it
```bash
scp deploy/provision.sh root@<vps-ip>:/root/
ssh root@<vps-ip> 'bash /root/provision.sh'
```
It will ask you to paste the **deploy public key** — see step 4 first to generate it.

### 3. DNS
Point both records at the VPS IP:
```
A   www.adwear.sk   <vps-ip>
A   adwear.sk       <vps-ip>
```

### 4. Deploy SSH key (CI → VPS)
Generate a dedicated key (no passphrase):
```bash
ssh-keygen -t ed25519 -f adwear-deploy -N "" -C "github-actions"
```
- **Public** key (`adwear-deploy.pub`) → paste when `provision.sh` asks.
- **Private** key (`adwear-deploy`) → add as the `SSH_KEY` secret in **all three** repos.

### 5. GitHub secrets (per repo)
In `PrestaShop`, `category-migrator`, `malfini-api` → Settings → Secrets → Actions:

| Secret | Value |
|--------|-------|
| `SSH_HOST` | VPS IP |
| `SSH_USER` | `deploy` |
| `SSH_KEY`  | the private `adwear-deploy` key |

### 6. Copy the stack to the VPS
```bash
ssh deploy@<vps-ip>
cd /opt/adwear
# copy these from the repo: docker-compose.yml, Caddyfile, caddy/Dockerfile
# (the deploy workflow does NOT sync them; after changing them, copy them over
# by hand — write the Caddyfile in place, it is a single-file bind mount — and
# run: docker compose up -d --no-deps --no-build caddy)
# The caddy image is NOT built on the VPS: compiling Caddy there fails (2 CPU /
# 4 GB next to MySQL). Build it locally and load it over SSH:
#   docker build -t adwear-caddy:latest deploy/caddy
#   docker save adwear-caddy:latest | gzip | ssh deploy@<vps-ip> 'gunzip | docker load'
# then create the secrets file:
cp .env.prod.example .env   # edit .env with real passwords
```

### 7. Let the VPS pull the private image
Create a GitHub PAT with `read:packages`, then once:
```bash
echo <PAT> | docker login ghcr.io -u <github-user> --password-stdin
```

### 8. First image build
Create the `production` branch in the fork and push it — this runs the
build+deploy workflow and publishes the first image to GHCR:
```bash
git checkout -b production && git push -u origin production
```

### 9. First install (writes parameters.php + populates the DB) — run ONCE
The prod image ships **without** `install-dev/` (removed in `deploy/Dockerfile`, and Caddy
refuses the path). For a fresh install, copy it in from a checkout of the same commit first,
and remove it right after:
`docker compose cp install-dev app:/var/www/html/install-dev` … run the command below …
`docker compose exec app rm -rf /var/www/html/install-dev`.
```bash
cd /opt/adwear
docker compose up -d mysql
docker compose up -d app
docker compose exec -u www-data app php install-dev/index_cli.php \
  --domain=www.adwear.sk --db_server=mysql \
  --db_name="$DB_NAME" --db_user="$DB_USER" --db_password="$DB_PASSWD" \
  --prefix="$DB_PREFIX" --name="Adwear" --country=sk --language=sk \
  --email=<admin-email> --password=<admin-password>
docker compose up -d caddy
docker compose exec -u www-data app php bin/console cache:clear --no-warmup
```
Visit https://www.adwear.sk — Caddy issues the TLS cert on first request.
Then deploy the custom modules + theme by pushing their repos.

### 10. Nightly backups
The deploy ships `backup.sh` and `borgmatic/config.yaml`, and installs the 03:15 cron from `crontab`.
`backup.sh` dumps and verifies the DB, keeps 14 days of dumps on the box, and sends the dump, the
`ps-img/-upload/-download/-config/-mails` volumes and `/opt/adwear` to an encrypted borg repo on a
Hetzner Storage Box (another location than the VPS, with automatic snapshots on). It runs borg
from the pinned `b3vis/borgmatic` image, so the VPS needs no borg and no root.

The **only** protection against a compromised VPS is the Storage Box's automatic snapshots: the
VPS key can prune and delete the repo, and only the Hetzner console can delete snapshots. Keep them on.

One-time setup, as `deploy`, after the deploy has shipped `borgmatic/config.yaml`:
```bash
cd /opt/adwear
ssh-keygen -t ed25519 -N '' -f ~/.ssh/storagebox
ssh-copy-id -p 23 -s -i ~/.ssh/storagebox.pub uNNN@uNNN.your-storagebox.de
ssh-keyscan -p 23 uNNN.your-storagebox.de > ~/.ssh/storagebox_known_hosts
ssh -p 23 -i ~/.ssh/storagebox uNNN@uNNN.your-storagebox.de borg --version   # expect 1.4.x
# .env: BORG_REPO=ssh://uNNN@uNNN.your-storagebox.de:23/./adwear
#       BORG_PASSPHRASE=$(openssl rand -hex 32)   (hex: no quotes or $ to trip up sourcing)
#       HC_BACKUP_URL=https://hc-ping.com/<uuid>  (grace: several hours, the first seed is long)
#       ALERT_URL=https://ntfy.sh/<topic>
set -a; . ./.env; set +a
borg() { docker run --rm -e BORG_REPO -e BORG_PASSPHRASE -e BORG_HOST_ID=adwear-backup \
  --mount type=bind,src=$PWD/borgmatic/config.yaml,dst=/etc/borgmatic/config.yaml,readonly \
  --mount type=bind,src=$HOME/.ssh/storagebox,dst=/root/.ssh/storagebox,readonly \
  --mount type=bind,src=$HOME/.ssh/storagebox_known_hosts,dst=/root/.ssh/known_hosts,readonly \
  -v adwear-borg-config:/root/.config/borg --entrypoint borgmatic b3vis/borgmatic:2.1.10 \
  -c /etc/borgmatic/config.yaml "$@"; }
borg repo-create --encryption repokey-blake2
borg key export          # paste the output into Bitwarden
```
Store the passphrase **and** the key export in Bitwarden: the repo can't be read with only one of
them. Until `BORG_REPO` is set, `backup.sh` makes the local dump only and reports the missing
off-site copy to healthchecks.

---

## Day-to-day

| You want to… | Do this |
|---|---|
| Ship core/fork changes | merge `develop` → `production`, push. CI builds + deploys. |
| Ship a module change | push to the module repo's `main`. |
| Ship a theme change | push the theme repo's `main`. |
| Roll back the app | `/opt/adwear/release.sh rollback` — back to the previous release (kept on disk, no pull), with all post-deploy steps. Run it again to return. Older: `release.sh list`, then `release.sh ghcr.io/adwear-sk/prestashop:<sha>`. Never just edit `APP_IMAGE` + `compose up`: that skips .htaccess, robots.txt, translations and the cache clear. Run as `deploy`, not root. A rollback does not undo applied `deploy/sql` migrations or the newer crontab and host scripts. |
| See what is live | `/opt/adwear/release.sh list` (newest last); `.env` pins `APP_IMAGE` to the exact `:<sha>`. |
| See logs | `docker compose logs -f app` |
| Restore DB | `gunzip < backups/db-<stamp>.sql.gz \| docker compose exec -T mysql mysql -uroot -p"$DB_ROOT_PASSWD" "$DB_NAME"` |

## Notes & gotchas
- **OPcache validation is off** for speed, so module/theme deploys **restart the `app` container** to pick up new code — the module workflows already do this.
- **Never deploy `develop` directly.** The `production` branch is the safety gate.
- **`.env` on the VPS holds all secrets** and is never committed.
- The custom theme repo doesn't exist yet — create it when you duplicate
  Classic (`themes/adwear`), give it the same 3 secrets, and a workflow that
  runs `cd _dev && npm ci && npm run build` then rsyncs to
  `/opt/adwear/custom/themes/adwear`.
