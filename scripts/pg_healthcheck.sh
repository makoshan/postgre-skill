#!/usr/bin/env bash
set -euo pipefail

URL=""
CONTAINER=""
QUERY="SELECT current_database(), current_user, now();"

usage() {
  cat <<'EOF'
Usage:
  pg_healthcheck.sh --url <postgres-url> [--container <docker-container>] [--query <sql>]

Examples:
  pg_healthcheck.sh --url "$TG_DB_URL"
  pg_healthcheck.sh --url "$TG_DB_URL" --container pg
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL="${2:-}"
      shift 2
      ;;
    --container)
      CONTAINER="${2:-}"
      shift 2
      ;;
    --query)
      QUERY="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "${URL}" ]]; then
  echo "Missing --url" >&2
  usage
  exit 2
fi

if [[ -n "${CONTAINER}" ]]; then
  docker exec "${CONTAINER}" psql "${URL}" -v ON_ERROR_STOP=1 -t -A -c "${QUERY}"
  exit 0
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "psql not found in PATH. Use --container <name> for Docker-hosted Postgres." >&2
  exit 3
fi

psql "${URL}" -v ON_ERROR_STOP=1 -t -A -c "${QUERY}"
