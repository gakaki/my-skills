#!/usr/bin/env bash
set -euo pipefail

echo "[disk]"
df -h / /var /var/lib

echo
echo "[var/lib top]"
du -xh --max-depth=2 /var/lib 2>/dev/null | sort -h | tail -n 30

echo
echo "[docker volumes top]"
du -xh --max-depth=1 /var/lib/docker/volumes 2>/dev/null | sort -h | tail -n 20

echo
echo "[big logs]"
find /var -type f \( -name '*.log' -o -name '*.err' -o -name '*.out' -o -name '*.json.log' \) -size +1M -printf '%s %p\n' 2>/dev/null | sort -nr | head -n 20

echo
echo "[clickhouse system log tables]"
curl -sS -u 'clickhouse:clickhouse' --data-binary "
SELECT database, table, formatReadableSize(total_bytes) AS size, total_rows
FROM system.tables
WHERE database='system'
  AND table IN (
    'trace_log',
    'text_log',
    'metric_log',
    'asynchronous_metric_log',
    'query_log',
    'query_metric_log',
    'error_log',
    'processors_profile_log',
    'opentelemetry_span_log'
  )
ORDER BY total_bytes DESC
FORMAT TabSeparated
" 'http://127.0.0.1:8123/'
