# PostgreSQL Install, Configure, and Use

## 1. Install

### Ubuntu/Debian (APT)

```bash
sudo apt-get update
sudo apt-get install -y postgresql postgresql-client
sudo systemctl enable --now postgresql
```

### macOS (Homebrew)

```bash
brew install postgresql@16
brew services start postgresql@16
```

### Docker (Local Dev)

```bash
docker run -d \
  --name pg \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=app \
  -p 5432:5432 \
  pgvector/pgvector:pg16
```

## 2. Create Role and Database

Connect as superuser and run:

```sql
CREATE ROLE app_user WITH LOGIN PASSWORD 'replace_me';
CREATE DATABASE app_db OWNER app_user;
```

Optional read-only role:

```sql
CREATE ROLE app_readonly WITH LOGIN PASSWORD 'replace_me';
GRANT CONNECT ON DATABASE app_db TO app_readonly;
```

## 3. Configure Network and Auth

Set in `postgresql.conf`:

```conf
listen_addresses = '127.0.0.1,localhost'
port = 5432
password_encryption = scram-sha-256
```

Set in `pg_hba.conf` (example):

```conf
# Local socket
local   all             all                                     scram-sha-256
# IPv4 localhost
host    all             all             127.0.0.1/32            scram-sha-256
```

Reload server:

```bash
sudo systemctl reload postgresql
```

## 4. Build Connection URL

```bash
export TG_DB_URL='postgres://app_user:replace_me@127.0.0.1:5432/app_db?sslmode=disable'
```

For remote/managed database:

```bash
export TG_DB_URL='postgres://app_user:replace_me@db.example.com:5432/app_db?sslmode=require'
```

## 5. Basic Usage

Initialize schema:

```bash
psql "$TG_DB_URL" -f ./schema.sql
```

Quick query:

```bash
psql "$TG_DB_URL" -c "SELECT now(), current_database(), current_user;"
```

Insert sample data:

```sql
CREATE TABLE IF NOT EXISTS notes (
  id BIGSERIAL PRIMARY KEY,
  body TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

INSERT INTO notes(body) VALUES ('postgres ready');
SELECT * FROM notes ORDER BY id DESC LIMIT 5;
```

## 6. App Integration Pattern

Use one env var in app runtime:

```bash
export DATABASE_URL="$TG_DB_URL"
```

Application code should:

- Open a pooled connection.
- Run migrations on deploy/startup workflow.
- Fail fast on startup if DB is unreachable.
- Use parameterized queries only.
