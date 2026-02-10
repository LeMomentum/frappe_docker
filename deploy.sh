#!/bin/bash
# =============================================================================
# Vooroo CRM - Script de déploiement production
# Usage: ./deploy.sh [--no-cache] [--skip-build] [--skip-migrate]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
SITE_NAME="lemomentum.tech"
IMAGE_NAME="custom-frappe"
IMAGE_TAG="latest"
FRAPPE_BRANCH="version-15"
PYTHON_VERSION="3.11.6"
NODE_VERSION="20.19.2"
GITHUB_PAT_FILE="$HOME/.vooroo_github_pat"

# Flags
NO_CACHE=""
SKIP_BUILD=false
SKIP_MIGRATE=false

for arg in "$@"; do
  case $arg in
    --no-cache) NO_CACHE="--no-cache" ;;
    --skip-build) SKIP_BUILD=true ;;
    --skip-migrate) SKIP_MIGRATE=true ;;
    --help) echo "Usage: $0 [--no-cache] [--skip-build] [--skip-migrate]"; exit 0 ;;
  esac
done

log() { echo "$(date '+%H:%M:%S') $1"; }

# =============================================================================
# 1. Pré-vérifications
# =============================================================================
log "🚀 Déploiement Vooroo CRM pour $SITE_NAME"

if [ ! -f "apps.json" ]; then
  log "❌ apps.json manquant"; exit 1
fi
if [ ! -f ".env" ]; then
  log "❌ .env manquant"; exit 1
fi

# =============================================================================
# 2. Backup de la base de données
# =============================================================================
log "💾 Backup de la base de données..."
docker compose exec -T backend bench --site "$SITE_NAME" backup --with-files 2>/dev/null || log "⚠️  Backup échoué (continue quand même)"

# =============================================================================
# 3. Build de l'image Docker
# =============================================================================
if [ "$SKIP_BUILD" = false ]; then
  log "📦 Construction de l'image Docker..."

  # Injecter le PAT GitHub pour le repo privé vooroo_saas
  if [ -f "$GITHUB_PAT_FILE" ]; then
    GITHUB_PAT=$(cat "$GITHUB_PAT_FILE" | tr -d '[:space:]')
  else
    log "⚠️  Fichier PAT non trouvé ($GITHUB_PAT_FILE)"
    log "   Créez-le avec: echo 'ghp_VOTRE_TOKEN' > $GITHUB_PAT_FILE && chmod 600 $GITHUB_PAT_FILE"
    read -rp "   Entrez le GitHub PAT (ou appuyez sur Entrée pour utiliser apps.json tel quel): " GITHUB_PAT
  fi

  # Préparer apps.json avec le PAT (temporaire)
  cp apps.json apps.json.bak
  if [ -n "${GITHUB_PAT:-}" ]; then
    python3 -c "
import json
with open('apps.json') as f:
    apps = json.load(f)
for app in apps:
    if 'vooroo_saas' in app.get('url', ''):
        app['url'] = app['url'].replace('https://github.com/', 'https://${GITHUB_PAT}@github.com/')
        if not app['url'].startswith('https://${GITHUB_PAT}@'):
            app['url'] = 'https://${GITHUB_PAT}@github.com/LeMomentum/vooroo_saas.git'
with open('apps.json', 'w') as f:
    json.dump(apps, f, indent=2)
print('PAT injecté dans apps.json')
"
  fi

  # Build
  APPS_JSON_BASE64=$(base64 -w 0 apps.json)

  docker build \
    $NO_CACHE \
    --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
    --build-arg=FRAPPE_BRANCH=$FRAPPE_BRANCH \
    --build-arg=PYTHON_VERSION=$PYTHON_VERSION \
    --build-arg=NODE_VERSION=$NODE_VERSION \
    --build-arg=APPS_JSON_BASE64="$APPS_JSON_BASE64" \
    --tag="${IMAGE_NAME}:${IMAGE_TAG}" \
    --file=images/custom/Containerfile .

  # Restaurer apps.json sans PAT
  mv apps.json.bak apps.json
  log "✅ Image construite: ${IMAGE_NAME}:${IMAGE_TAG}"
else
  log "⏭️  Build ignoré (--skip-build)"
fi

# =============================================================================
# 4. Déployer les containers
# =============================================================================
log "🔄 Mise à jour des containers..."
docker compose down --timeout 30
docker compose up -d --remove-orphans

log "⏳ Attente du démarrage des services (20s)..."
sleep 20

# Vérifier que le backend est prêt
for i in $(seq 1 10); do
  if docker compose exec -T backend bench --site "$SITE_NAME" show-config >/dev/null 2>&1; then
    log "✅ Backend prêt"
    break
  fi
  if [ "$i" -eq 10 ]; then
    log "❌ Backend non prêt après 60s"
    docker compose logs backend --tail 20
    exit 1
  fi
  sleep 4
done

# =============================================================================
# 5. Migration et mise à jour
# =============================================================================
if [ "$SKIP_MIGRATE" = false ]; then
  log "🛠️  Migration de la base de données..."
  docker compose exec -T backend bench --site "$SITE_NAME" migrate

  log "🧹 Nettoyage du cache..."
  docker compose exec -T backend bench --site "$SITE_NAME" clear-cache
else
  log "⏭️  Migration ignorée (--skip-migrate)"
fi

# =============================================================================
# 6. Rebuild frontend SPA & sync assets
# =============================================================================
log "📦 Rebuild du frontend SPA..."
BACKEND_CONTAINER=$(docker compose ps -q backend)
FRONTEND_CONTAINER=$(docker compose ps -q frontend)

if [ -n "$BACKEND_CONTAINER" ]; then
  # Rebuild the vooroo_saas frontend SPA inside the container
  docker exec "$BACKEND_CONTAINER" bash -c "
    cd /home/frappe/frappe-bench/apps/vooroo_saas/frontend && \
    NODE_ENV=production yarn build 2>&1 | tail -5
  " && log "✅ Frontend SPA rebuilt" || log "⚠️  Frontend build skipped (yarn not available or build failed)"

  # Sync vooroo_crm.html with the actual compiled filenames
  docker exec "$BACKEND_CONTAINER" bash -c "
    INDEX_HTML='/home/frappe/frappe-bench/apps/vooroo_saas/vooroo_saas/public/frontend/index.html'
    CRM_HTML='/home/frappe/frappe-bench/apps/vooroo_saas/vooroo_saas/www/vooroo_crm.html'
    if [ -f \"\$INDEX_HTML\" ] && [ -f \"\$CRM_HTML\" ]; then
      JS_FILE=\$(grep -o 'index-[^\"]*\.js' \"\$INDEX_HTML\" | head -1)
      CSS_FILE=\$(grep -o 'index-[^\"]*\.css' \"\$INDEX_HTML\" | head -1)
      if [ -n \"\$JS_FILE\" ]; then
        sed -i \"s|index-[^\\\"]*\\.js|\$JS_FILE|g\" \"\$CRM_HTML\"
      fi
      if [ -n \"\$CSS_FILE\" ]; then
        sed -i \"s|index-[^\\\"]*\\.css|\$CSS_FILE|g\" \"\$CRM_HTML\"
      fi
      echo \"vooroo_crm.html synced: JS=\$JS_FILE CSS=\$CSS_FILE\"
    fi
  " && log "✅ vooroo_crm.html synced with build output"
fi

log "📁 Synchronisation des assets..."

if [ -n "$BACKEND_CONTAINER" ] && [ -n "$FRONTEND_CONTAINER" ]; then
  # Créer un tar des assets en suivant les symlinks
  docker exec "$BACKEND_CONTAINER" tar -chf /tmp/assets.tar -C /home/frappe/frappe-bench/sites assets/ 2>/dev/null
  docker cp "$BACKEND_CONTAINER":/tmp/assets.tar /tmp/assets.tar 2>/dev/null
  docker cp /tmp/assets.tar "$FRONTEND_CONTAINER":/tmp/assets.tar 2>/dev/null
  docker exec "$FRONTEND_CONTAINER" tar -xf /tmp/assets.tar -C /home/frappe/frappe-bench/sites/ 2>/dev/null
  # Nettoyage
  docker exec "$BACKEND_CONTAINER" rm -f /tmp/assets.tar 2>/dev/null
  docker exec "$FRONTEND_CONTAINER" rm -f /tmp/assets.tar 2>/dev/null
  rm -f /tmp/assets.tar
  log "✅ Assets synchronisés"
else
  log "⚠️  Impossible de synchroniser les assets (containers introuvables)"
fi

# =============================================================================
# 7. Vérification finale
# =============================================================================
log "🔍 Vérification du site..."
HTTP_CODE=$(docker compose exec -T backend python3 -c "
import urllib.request
try:
    r = urllib.request.urlopen('http://localhost:8000', timeout=10)
    print(r.status)
except Exception as e:
    print(f'ERR: {e}')
" 2>/dev/null || echo "ERR")

if echo "$HTTP_CODE" | grep -q "200\|301\|302"; then
  log "✅ Site accessible (HTTP $HTTP_CODE)"
else
  log "⚠️  Site retourne: $HTTP_CODE"
fi

# Nettoyage des anciennes images
docker image prune -f >/dev/null 2>&1 || true

log "🎉 Déploiement terminé!"
log "   Site: https://$SITE_NAME"
log "   Admin: https://$SITE_NAME/app-admin"