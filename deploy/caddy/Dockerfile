# Caddy with the rate_limit handler (github.com/mholt/caddy-ratelimit), which
# the stock image lacks. Built locally and loaded onto the VPS (see README);
# keep the version in step with the stock image it replaces.
ARG CADDY_VERSION=2.11.4

FROM caddy:${CADDY_VERSION}-builder AS build
RUN xcaddy build --with github.com/mholt/caddy-ratelimit@v0.1.0

FROM caddy:${CADDY_VERSION}-alpine
COPY --from=build /usr/bin/caddy /usr/bin/caddy
