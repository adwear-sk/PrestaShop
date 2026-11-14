# Production image for www.adwear.sk
# Built in CI (GitHub Actions), pushed to GHCR, pulled by the VPS.
# Multi-stage: the "build" stage runs composer + the asset build (needs Node);
# the final stage ships only the runnable result (no Node, no dev deps).

# PHP 8.4: security fixes until 2028-12-31 (8.1 lost them at the end of 2025).
# 8.5 is out of reach while phpoffice/phpspreadsheet pins php <8.5.
ARG VERSION="8.4-apache"

# ---------------------------------------------------------------------------
# Stage 1 — build: composer install --no-dev + ./tools/assets/build.sh all
# ---------------------------------------------------------------------------
FROM prestashop/base:${VERSION} AS build

ARG NODE_VERSION=20.19.5
# Unguessable back-office folder name, injected from a CI secret (never committed
# — the repo is public). Defaults to admin-dev so local/plain builds are unchanged.
ARG ADMIN_FOLDER=admin-dev
ENV COMPOSER_ALLOW_SUPERUSER=1

# Node (for the PrestaShop asset build) + composer
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*
RUN php -r "copy('https://getcomposer.org/installer','/tmp/c.php');" \
  && php /tmp/c.php --install-dir=/usr/local/bin --filename=composer \
  && rm -f /tmp/c.php

WORKDIR /var/www/html
COPY . .

# Rename the back-office folder to the unguessable name BEFORE building, so the
# admin assets compile under the final path and nothing references admin-dev.
# PrestaShop derives _PS_ADMIN_DIR_ from the folder itself, so the rename is
# transparent to the app once the prod cache is rebuilt (done on deploy).
RUN if [ -n "$ADMIN_FOLDER" ] && [ "$ADMIN_FOLDER" != "admin-dev" ] && [ -d admin-dev ]; then \
      mv admin-dev "$ADMIN_FOLDER"; \
    fi

# Native modules + the Classic theme are pulled here (they are gitignored in
# the repo and resolved from packagist as prestashop/* packages).
RUN COMPOSER_PROCESS_TIMEOUT=600 COMPOSER_IPRESOLVE=4 \
    composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-progress

# Build admin + front assets (admin BO assets are NOT committed, so this is
# required). build.sh reads ADMIN_DIR (default admin-dev) to locate the BO theme.
RUN ADMIN_DIR="${ADMIN_FOLDER}" ./tools/assets/build.sh all --force

# ---------------------------------------------------------------------------
# Stage 2 — runtime: plain Apache + the built app. No auto-install.
# ---------------------------------------------------------------------------
FROM prestashop/base:${VERSION}

# Production PHP tuning (opcache on, errors off, etc.)
COPY deploy/php-prod.ini /usr/local/etc/php/conf.d/zz-adwear-prod.ini

# Apache sees every request as coming from Caddy. Take the client IP from the
# X-Forwarded-For header Caddy sets (it replaces any client-sent value), so the
# access log and REMOTE_ADDR carry the real visitor address.
RUN a2enmod remoteip \
  && printf '%s\n' \
    'RemoteIPHeader X-Forwarded-For' \
    'RemoteIPInternalProxy 172.16.0.0/12' \
    'LogFormat "%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined' \
    > /etc/apache2/conf-available/remoteip.conf \
  && a2enconf remoteip

# Cap Apache at 24 mod_php workers. The default 150 met MySQL's 151 connection
# limit, so a flood used up every DB connection (peak 152 on 2026-11-10) and each
# worker can take memory_limit 512M on a 3.7 GB box. Extra requests now queue
# in the listen backlog instead. 24 is provisional until perf-load-test sets it.
# Recycling workers every 1000 requests bounds slow leaks. ServerTokens and
# ServerSignature stop the Apache and Debian versions leaking in headers and error pages.
RUN printf '%s\n' \
    '<IfModule mpm_prefork_module>' \
    '    StartServers            4' \
    '    MinSpareServers         4' \
    '    MaxSpareServers         8' \
    '    ServerLimit             24' \
    '    MaxRequestWorkers       24' \
    '    MaxConnectionsPerChild  1000' \
    '</IfModule>' \
    > /etc/apache2/mods-available/mpm_prefork.conf \
  && sed -i -e 's/^ServerTokens .*/ServerTokens Prod/' -e 's/^ServerSignature .*/ServerSignature Off/' \
    /etc/apache2/conf-available/security.conf \
  && grep -q '^ServerTokens Prod' /etc/apache2/conf-available/security.conf \
  && grep -q '^ServerSignature Off' /etc/apache2/conf-available/security.conf

# Copy the fully built application from the build stage.
COPY --from=build --chown=www-data:www-data /var/www/html /var/www/html

WORKDIR /var/www/html

# Nothing a live shop needs: the web installer (reachable at /install-dev/ until
# 2026-11-11), the git metadata and repo-only files. Caddy also refuses these
# paths, so an image built before this line stays covered.
RUN rm -rf install-dev .git .github docker-compose.yml Makefile bin/worktree.sh bin/pull-prod.sh

# Production mode: the develop branch defaults _PS_MODE_DEV_ to true. Force it
# off so the live store never runs in debug mode (no stack traces, faster).
RUN sed -i "s/define('_PS_MODE_DEV_', true)/define('_PS_MODE_DEV_', false)/" config/defines.inc.php

# Trust the reverse proxy (Caddy) so PrestaShop sees HTTPS behind TLS
# termination. Under Apache/mod_php the docker-compose env var is NOT exposed
# to PHP's $_SERVER, and the shipped .env sets PS_TRUSTED_PROXIES empty — so
# Symfony's $request->isSecure() returns false and the BO refuses login with
# "you cannot connect to the back office until SSL is activated". Setting it in
# .env.local (loaded by PrestaShop's Dotenv cascade, overriding .env) fixes it.
RUN echo "PS_TRUSTED_PROXIES=172.16.0.0/12" > .env.local \
  && chown www-data:www-data .env.local

# mails/ is a named volume, which hides the image's mails/themes (the git-managed
# mail layouts). Keep a copy outside it so the deploy can sync them in.
RUN cp -a mails/themes /usr/local/share/adwear-mail-themes

# app/config is a named volume too (it holds parameters.php), which hid every
# upstream config change from prod. Same fix: a copy the deploy syncs in. The
# per-instance parameters files are never part of it.
RUN cp -a app/config /usr/local/share/adwear-app-config \
  && rm -f /usr/local/share/adwear-app-config/parameters.php /usr/local/share/adwear-app-config/parameters.yml

# The directories PrestaShop writes to at runtime are mounted as volumes in
# docker-compose; make sure their mount points are owned by www-data.
RUN mkdir -p img upload download var mails app/config \
  && chown -R www-data:www-data img upload download var mails app/config

# prestashop/base's default CMD starts Apache on :80. No docker_run_git.sh,
# so the container never tries to (re)install or rebuild on boot.
EXPOSE 80
