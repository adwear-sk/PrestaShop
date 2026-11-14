#!/usr/bin/env bash
# Weekly MySQL housekeeping. Install on the VPS via deploy/crontab (the deploy
# workflow copies this file to /opt/adwear/).
#
# Rotates the slow query log that release.sh switches on (long_query_time 2 s,
# /var/lib/mysql/slow.log inside the db-data volume). Unrotated it would grow
# without bound on the same disk that filled up on 2026-11-04. Keeps the
# current file plus 4 weeks (slow.log.1 .. slow.log.4); FLUSH SLOW LOGS makes
# mysqld reopen a fresh slow.log after the rename.
#
# Then logs a weekly query report from performance_schema (see below).
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

# Weekly query report: which statements cost the most this week, in total and
# per single run, plus the counters that show memory and connection pressure.
# The digest table is reset afterwards, so each report covers one week.
# Status counters are cumulative since mysqld started (Uptime), so compare
# reports by their difference.
echo "[$(date -u '+%F %T')] query report"
docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot -t' <<'SQL'
SELECT COUNT_STAR AS runs, ROUND(SUM_TIMER_WAIT / 1e12) AS total_s,
       ROUND(AVG_TIMER_WAIT / 1e9) AS avg_ms, ROUND(MAX_TIMER_WAIT / 1e12, 1) AS max_s,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR) AS rows_examined, LEFT(DIGEST_TEXT, 110) AS query
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL ORDER BY SUM_TIMER_WAIT DESC LIMIT 20;
SELECT COUNT_STAR AS runs, ROUND(MAX_TIMER_WAIT / 1e12, 1) AS max_s, LEFT(DIGEST_TEXT, 140) AS slowest_single_runs
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL ORDER BY MAX_TIMER_WAIT DESC LIMIT 10;
SHOW GLOBAL STATUS WHERE Variable_name IN ('Uptime', 'Questions', 'Slow_queries',
  'Max_execution_time_exceeded', 'Max_used_connections', 'Connection_errors_max_connections',
  'Threads_created', 'Innodb_buffer_pool_reads', 'Innodb_buffer_pool_read_requests',
  'Created_tmp_disk_tables', 'Created_tmp_tables');
TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;
SQL
