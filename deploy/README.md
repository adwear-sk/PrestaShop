# Production deployment — www.adwear.sk

A push-to-deploy setup for a single PrestaShop store on a Hetzner VPS.

## How it works

```
  GitHub (adwear-sk)                    GitHub Actions                 Hetzner VPS (/opt/adwear)
  ──────────────────                    ──────────────                 ─────────────────────────
  PrestaShop (fork)   ─push production→  composer + asset build  ─GHCR→  app  ← Caddy (auto-TLS) ← :443
                                          → Docker image → GHCR    ─ssh→  docker compose pull && up -d
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
| `Caddyfile` | Auto-HTTPS for www.adwear.sk |
| `php-prod.ini` | Production PHP/OPcache tuning |
| `.env.prod.example` | Template for the server's secrets file |
| `provision.sh` | One-time VPS hardening + Docker install |
| `backup.sh` | Nightly DB dump (cron) |

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
# copy these from the repo: docker-compose.yml, Caddyfile
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
```bash
cp deploy/backup.sh /opt/adwear/ && chmod +x /opt/adwear/backup.sh
crontab -e
# add:
15 3 * * *  /opt/adwear/backup.sh >> /opt/adwear/backups/backup.log 2>&1
```

---

## Day-to-day

| You want to… | Do this |
|---|---|
| Ship core/fork changes | merge `develop` → `production`, push. CI builds + deploys. |
| Ship a module change | push to the module repo's `main`. |
| Ship a theme change | push the theme repo's `main`. |
| Roll back the app | set `APP_IMAGE=ghcr.io/adwear-sk/prestashop:<previous-sha>` in `/opt/adwear/.env`, then `docker compose up -d app`. |
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
