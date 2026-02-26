# postgre-skill

PostgreSQL 实战型 Codex Skill。  
安装和配置只保留最小步骤，重点覆盖“如何在项目里正确使用 Postgres”。

## 这个 Skill 解决什么问题

- 用最短步骤把 Postgres 跑起来并拿到可用连接串（`TG_DB_URL` / `DATABASE_URL`）
- 规范日常使用流程：建表、查询、索引、事务、分页、upsert
- 提供可执行连通性检查脚本，快速判断“能不能连、权限对不对”
- 提供故障定位思路（认证失败、连不上、慢查询、锁等待）

## 文件结构

```text
.
├── SKILL.md
├── agents/openai.yaml
├── references/install-config-usage.md
└── scripts/pg_healthcheck.sh
```

## 快速开始

1. 准备连接串：

```bash
export TG_DB_URL='postgres://app_user:replace_me@127.0.0.1:5432/app_db?sslmode=disable'
```

2. 连通性检查（本机有 `psql`）：

```bash
scripts/pg_healthcheck.sh --url "$TG_DB_URL"
```

3. 连通性检查（Postgres 在 Docker 容器）：

```bash
scripts/pg_healthcheck.sh --url "$TG_DB_URL" --container pg
```

## 在 Codex 中使用

直接在请求中显式调用：

```text
Use $postgre-skill to optimize this SQL and add proper indexes.
```

或中文：

```text
用 $postgre-skill 帮我检查这段 SQL 的性能，并给出索引和事务建议。
```

## 重点能力（Usage-first）

- 先检查现状再改库（表结构、索引、数据分布）
- 用 migration/SQL 文件管理 schema 变更
- 在应用代码中坚持参数化 SQL
- 根据读路径补索引，并用 `EXPLAIN (ANALYZE, BUFFERS)` 验证
- 多步写入必须用事务，失败可回滚
- 备份和恢复都要演练，不只做备份

## 参考文档

- 安装、配置、基础 SQL：`references/install-config-usage.md`
- 健康检查脚本：`scripts/pg_healthcheck.sh`
