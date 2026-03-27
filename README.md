# my-skills

## Skills

### `langfuse-clickhouse-slimming`

用于排查和压缩自托管 Langfuse + ClickHouse 的磁盘占用。

覆盖内容：

- Docker 容器日志与 volume 文本日志清理
- ClickHouse `system.*_log` 表体积排查与 `TRUNCATE`
- Langfuse ClickHouse 持久化降噪配置
- `docker compose` 方式的安全重建与验收

目录：

- `langfuse-clickhouse-slimming/SKILL.md`
- `langfuse-clickhouse-slimming/references/triage.md`
- `langfuse-clickhouse-slimming/references/persistence.md`
- `langfuse-clickhouse-slimming/scripts/audit_langfuse_clickhouse.sh`
