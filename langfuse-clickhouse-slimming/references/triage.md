# 诊断与清理

先查根盘：

```bash
df -h / /var /var/lib
du -xh --max-depth=2 /var/lib 2>/dev/null | sort -h | tail -n 40
du -xh --max-depth=1 /var/lib/docker/volumes 2>/dev/null | sort -h | tail -n 20
```

重点看：

- `/var/lib/docker/volumes/langfuse_langfuse_clickhouse_data`
- `/var/lib/docker/containers/*/*-json.log`
- `/var/log/messages`
- `/var/log/sa/*`
- `journalctl --disk-usage`

清理可直接截断的日志：

```bash
find /var/lib/docker/containers -type f -name '*-json.log' -exec truncate -s 0 {} +
find /var/lib/docker/volumes -type f \( -name '*.log' -o -name '*.err.log' \) -exec truncate -s 0 {} +
truncate -s 0 /var/log/messages
journalctl --vacuum-size=50M
dnf clean all
```

如果大头在 ClickHouse volume，不要删底层文件，先连 ClickHouse：

```bash
curl -u 'clickhouse:clickhouse' 'http://127.0.0.1:8123/?query=SELECT%201'
```

查看系统日志表大小：

```sql
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
ORDER BY total_bytes DESC;
```

安全清理系统日志表：

```sql
TRUNCATE TABLE system.trace_log;
TRUNCATE TABLE system.text_log;
TRUNCATE TABLE system.metric_log;
TRUNCATE TABLE system.asynchronous_metric_log;
TRUNCATE TABLE system.query_log;
TRUNCATE TABLE system.query_metric_log;
TRUNCATE TABLE system.error_log;
TRUNCATE TABLE system.processors_profile_log;
TRUNCATE TABLE system.opentelemetry_span_log;
```
