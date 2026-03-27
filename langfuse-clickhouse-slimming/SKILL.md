---
name: 减肥langfuse和clickhouse
description: 用于排查和压缩自托管 Langfuse + ClickHouse 的磁盘占用，尤其适合 /var/lib/docker/volumes/langfuse_langfuse_clickhouse_data 膨胀、system.trace_log 或 system.text_log 暴涨、需要持久化 ClickHouse 降噪配置、以及安全清理 Docker 和 ClickHouse 日志的场景。
---

# 减肥langfuse和clickhouse

在自托管 Langfuse 磁盘暴涨时使用这个 skill。

优先处理顺序：

1. 先看根盘和 `/var/lib` 体积，再确认是不是 `langfuse_langfuse_clickhouse_data`。
2. 区分“文件日志”与“ClickHouse 系统日志表数据”。
3. 先清 Docker `json.log`、volume 文本日志、`journalctl`、`/var/log/messages` 这类可直接截断的内容。
4. 如果大头在 ClickHouse 数据 volume，优先查询 `system.tables`，不要直接删底层 MergeTree 文件。
5. 对 `system.trace_log`、`system.text_log`、`system.metric_log`、`system.asynchronous_metric_log` 用 SQL `TRUNCATE`。
6. 把 ClickHouse 降噪配置持久化到 compose bind mount，再重建 `clickhouse` 服务。
7. 重建后再次核对 `system.server_settings` 与 `system.settings`，确认 profiler 和日志级别已生效。

必读参考：

- 诊断与清理命令：`references/triage.md`
- 持久化配置与重建：`references/persistence.md`
- 快速巡检脚本：`scripts/audit_langfuse_clickhouse.sh`

关键原则：

- 不要直接删除 `langfuse_langfuse_clickhouse_data/_data/store/*` 里的 ClickHouse 数据分片。
- `system.trace_log` 的核心止血点不只是 `query_profiler_*`，还包括：
  - `global_profiler_cpu_time_period_ns=0`
  - `global_profiler_real_time_period_ns=0`
  - `total_memory_profiler_step=0`
- 仅 `docker restart` 不会吃到新的 bind mount；更新 compose 挂载后，需要 `docker compose up -d --no-deps --force-recreate clickhouse`。
- 如果只是文本日志膨胀，可直接截断；如果是 ClickHouse 系统表膨胀，必须用 SQL 清理。
- 先保留业务数据，只清 `system.*_log` 这类系统日志表。

验收标准：

1. `df -h /` 可用空间明显回升。
2. `system.server_settings` 中 `global_profiler_*` 和 `total_memory_profiler_step` 为 `0`。
3. `system.settings` 中 `query_profiler_*` 为 `0`。
4. `system.trace_log`、`system.text_log`、`system.metric_log`、`system.asynchronous_metric_log` 不再高速增长。
