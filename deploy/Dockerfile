# Production image for www.adwear.sk
# Built in CI (GitHub Actions), pushed to GHCR, pulled by the VPS.
# Multi-stage: the "build" stage runs composer + the asset build (needs Node);
# the final stage ships only the runnable result (no Node, no dev deps).

ARG VERSION="8.1-apache"

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

# Copy the fully built application from the build stage.
COPY --from=build --chown=www-data:www-data /var/www/html /var/www/html

WORKDIR /var/www/html

# Production mode: the develop branch defaults _PS_MODE_DEV_ to true. Force it
# off so the live store never runs in debug mode (no stack traces, faster).
RUN sed -i "s/define('_PS_MODE_DEV_', true)/define('_PS_MODE_DEV_', false)/" config/defines.inc.php

# The directories PrestaShop writes to at runtime are mounted as volumes in
# docker-compose; make sure their mount points are owned by www-data.
RUN mkdir -p img upload download var mails app/config \
  && chown -R www-data:www-data img upload download var mails app/config

# prestashop/base's default CMD starts Apache on :80. No docker_run_git.sh,
# so the container never tries to (re)install or rebuild on boot.
EXPOSE 80
