#!/usr/bin/env bash
# Weekly MySQL housekeeping. Install on the VPS via deploy/crontab (the deploy
# workflow copies this file to /opt/adwear/).
#
# Rotates the slow query log that release.sh switches on (long_query_time 2 s,
# /var/lib/mysql/slow.log inside the db-data volume). Unrotated it would grow
# without bound on the same disk that filled up on 2026-11-04. Keeps the
# current file plus 4 weeks (slow.log.1 .. slow.log.4); FLUSH SLOW LOGS makes
# mysqld reopen a fresh slow.log after the rename.
set -euo pipefail

cd /opt/adwear

echo "[$(date -u '+%F %T')] rotating slow log"
docker compose exec -T mysql sh -c '
    set -e
    cd /var/lib/mysql
    # No slow.log: either nothing was slow yet, or last run renamed it and then
    # failed to flush, so mysqld still writes to slow.log.1. Flushing recovers both.
    if [ ! -f slow.log ]; then
        MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "FLUSH SLOW LOGS"
        echo "  no slow.log; flushed so mysqld reopens it"
        exit 0
    fi
    rm -f slow.log.4
    for i in 3 2 1; do
        [ ! -f slow.log.$i ] || mv slow.log.$i slow.log.$((i + 1))
    done
    mv slow.log slow.log.1
    MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "FLUSH SLOW LOGS"
    echo "  slow.log.1: $(wc -l < slow.log.1) lines"
'
