---
name: postgre-skill
description: Install and configure PostgreSQL with minimal setup steps, then focus on practical usage in real projects. Use when tasks involve writing SQL, designing tables/indexes, querying and updating data safely, integrating apps via TG_DB_URL or DATABASE_URL, debugging DB issues, and operating backups/restores.
---

# Postgres Setup

## Overview

Keep install/config simple, spend most effort on correct daily usage: schema design, queries, transactions, indexing, and app integration.

## Minimal Setup (Keep It Short)

1. Install and start PostgreSQL (APT/Brew/Docker commands in [references/install-config-usage.md](references/install-config-usage.md)).
2. Create one app role and one app database.
3. Export connection URL:
```bash
export TG_DB_URL='postgres://app_user:replace_me@127.0.0.1:5432/app_db?sslmode=disable'
```
4. Verify connection:
```bash
scripts/pg_healthcheck.sh --url "$TG_DB_URL"
```

## Usage-First Workflow

1. Inspect current state before changing anything.
Run:
```bash
psql "$TG_DB_URL" -c '\dt'
psql "$TG_DB_URL" -c '\d+ your_table'
```

2. Manage schema explicitly.
Use SQL files/migrations, avoid ad-hoc manual edits.
```bash
psql "$TG_DB_URL" -f ./schema.sql
```

3. Use safe query patterns.
Always use parameterized SQL in app code.
Write explicit columns, avoid `SELECT *` in app paths.

4. Add indexes based on read paths.
Create indexes for frequent filters/sorts.
Validate with `EXPLAIN (ANALYZE, BUFFERS)`.

5. Use transactions for multi-step writes.
Group related writes with `BEGIN ... COMMIT`.
Rollback on any failure.

6. Operate data lifecycle.
Backup with `pg_dump`, restore with `psql` or `pg_restore`.
Test restore periodically, not only backup creation.

## Practical SQL Patterns

- Latest N records:
```sql
SELECT id, created_at, payload
FROM events
ORDER BY created_at DESC
LIMIT 50;
```

- Upsert:
```sql
INSERT INTO users (user_id, name, updated_at)
VALUES ($1, $2, now())
ON CONFLICT (user_id)
DO UPDATE SET name = EXCLUDED.name, updated_at = now();
```

- Pagination (stable order):
```sql
SELECT id, created_at, text
FROM messages
WHERE chat_id = $1 AND created_at < $2
ORDER BY created_at DESC
LIMIT $3;
```

## App Integration Notes

- Keep one canonical env var (`TG_DB_URL` or `DATABASE_URL`) and map consistently.
- Use connection pooling (`pgxpool`, `asyncpg.create_pool`, etc.).
- Fail fast on startup if DB is unreachable.
- Log slow queries and monitor row counts/index usage.

## Troubleshooting

- Auth errors: verify role password and `pg_hba.conf` rule match.
- Connection refused: service/listen address/port/firewall mismatch.
- Slow query: check `EXPLAIN`, missing indexes, and unbounded scans.
- Deadlock/lock wait: shorten transactions and keep write order consistent.

## Resources

- Commands and SQL examples:
[references/install-config-usage.md](references/install-config-usage.md)
- Quick connection checker:
`scripts/pg_healthcheck.sh`
