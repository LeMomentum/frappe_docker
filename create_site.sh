#!/bin/bash
set -e
source .env

docker compose exec -T backend bash -c "
bench new-site app.lemomentum.tech \
  --db-root-username=root \
  --db-host=db \
  --db-root-password='${DB_PASSWORD}' \
  --admin-password='admin' \
  --install-app crm \
  --install-app vooroo_saas \
  --force

bench use app.lemomentum.tech
"
echo "✅ Site créé avec succès"