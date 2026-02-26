---
name: postgre-skill
description: Use when asked to install/configure PostgreSQL, run operational SQL workflows, design/query schema safely, wire app connections via TG_DB_URL or DATABASE_URL, troubleshoot DB errors, or manage backup/restore.
---

# Postgres Skill

## Scope

Use this skill for PostgreSQL setup and day-to-day operations: schema design, safe DML, indexing, app integration, performance checks, and recovery tasks.

## Core workflow

1. Install and start PostgreSQL.
2. Create/confirm one app role and one app database.
3. Set one connection variable: `TG_DB_URL` or `DATABASE_URL`.
4. Verify connectivity before changing data.
5. Apply changes via migrations or SQL scripts, not ad-hoc console edits.
6. Validate each step with quick checks, then monitor for regressions.

## Safe usage standards

- Use explicit columns instead of `SELECT *`.
- Use parameterized query placeholders in application code.
- Use transactions for multi-step writes and rollback on partial failure.
- Add indexes where read paths are stable and validated with `EXPLAIN (ANALYZE, BUFFERS)`.

## Useful command patterns

```bash
psql "$TG_DB_URL" -c '\dt'
psql "$TG_DB_URL" -c '\d+ your_table'
psql "$TG_DB_URL" -c "EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM ..."
```

```bash
export TG_DB_URL='postgres://app_user:replace_me@127.0.0.1:5432/app_db?sslmode=disable'
```

```bash
scripts/pg_healthcheck.sh --url "$TG_DB_URL"
```

## SQL pattern examples

```sql
SELECT id, created_at, payload
FROM events
ORDER BY created_at DESC
LIMIT 50;
```

```sql
INSERT INTO users (user_id, name, updated_at)
VALUES ($1, $2, now())
ON CONFLICT (user_id)
DO UPDATE
SET name = EXCLUDED.name,
    updated_at = now();
```

```sql
SELECT id, created_at, text
FROM messages
WHERE chat_id = $1 AND created_at < $2
ORDER BY created_at DESC
LIMIT $3;
```

## Quick health checklist

- Can `psql` connect with the configured URL.
- Are migrations idempotent and versioned.
- Are slow queries indexed and explain plans stable.
- Are backups/restores tested with `pg_dump`/`psql` or `pg_restore`.
- Are deadlocks/minor contention reduced by shortening transaction scope.
