# 持久化配置

推荐在 Langfuse compose 项目里增加两个宿主机文件：

- `./ops/clickhouse/config.d/log-volume-control.xml`
- `./ops/clickhouse/users.d/profile-log-volume-control.xml`

`log-volume-control.xml` 示例：

```xml
<clickhouse>
    <logger>
        <level>warning</level>
    </logger>
    <text_log>
        <level>warning</level>
    </text_log>
    <metric_log>
        <collect_interval_milliseconds>60000</collect_interval_milliseconds>
        <flush_interval_milliseconds>60000</flush_interval_milliseconds>
    </metric_log>
    <asynchronous_metric_log>
        <flush_interval_milliseconds>60000</flush_interval_milliseconds>
    </asynchronous_metric_log>
    <global_profiler_cpu_time_period_ns>0</global_profiler_cpu_time_period_ns>
    <global_profiler_real_time_period_ns>0</global_profiler_real_time_period_ns>
    <total_memory_profiler_step>0</total_memory_profiler_step>
    <total_memory_tracker_sample_probability>0</total_memory_tracker_sample_probability>
</clickhouse>
```

`profile-log-volume-control.xml` 示例：

```xml
<clickhouse>
    <profiles>
        <default>
            <query_profiler_cpu_time_period_ns>0</query_profiler_cpu_time_period_ns>
            <query_profiler_real_time_period_ns>0</query_profiler_real_time_period_ns>
        </default>
    </profiles>
</clickhouse>
```

compose 挂载：

```yaml
services:
  clickhouse:
    volumes:
      - langfuse_clickhouse_data:/var/lib/clickhouse
      - langfuse_clickhouse_logs:/var/log/clickhouse-server
      - ./ops/clickhouse/config.d/log-volume-control.xml:/etc/clickhouse-server/config.d/log-volume-control.xml:ro
      - ./ops/clickhouse/users.d/profile-log-volume-control.xml:/etc/clickhouse-server/users.d/profile-log-volume-control.xml:ro
```

应用方式：

```bash
docker compose -f /home/langfuse/docker-compose.yml up -d --no-deps --force-recreate clickhouse
```
