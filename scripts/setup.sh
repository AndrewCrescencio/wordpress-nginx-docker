#!/bin/bash
# =============================================================
# scripts/setup.sh
# Script de onboarding para novos desenvolvedores
# Uso: bash scripts/setup.sh
# =============================================================

set -euo pipefail

# ─── Cores para output ──────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step()  { echo -e "\n${CYAN}═══ $1 ═══${NC}"; }

# ─── 1. Verificar pré-requisitos ────────────────────────────
step "Verificando pré-requisitos"

if ! command -v docker &>/dev/null; then
    error "Docker não encontrado. Instale: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! docker compose version &>/dev/null; then
    error "Docker Compose não encontrado."
    exit 1
fi

info "Docker: $(docker --version)"
info "Compose: $(docker compose version --short 2>/dev/null || echo 'disponível')"

# ─── 2. Criar .env a partir do exemplo ──────────────────────
step "Configuração do ambiente"

if [ ! -f .env ]; then
    cp .env.example .env
    info ".env criado a partir de .env.example"
    info "Revise as variáveis em .env antes de continuar."
else
    warn ".env já existe — mantendo configuração atual"
fi

# Carrega as variáveis do .env (apenas as que o script precisa)
set -a
source .env
set +a

# ─── 3. Criar diretórios necessários ────────────────────────
mkdir -p logs/nginx
info "Diretórios de log criados"

# ─── 4. Subir os containers ─────────────────────────────────
step "Subindo containers Docker"

info "Iniciando serviços..."
docker compose up -d

# ─── 5. Aguardar banco de dados ─────────────────────────────
step "Aguardando banco de dados"

info "Aguardando MariaDB ficar saudável..."
until docker compose exec -T db mariadb-admin ping --silent 2>/dev/null; do
    sleep 2
done
info "Banco de dados pronto!"

# ─── 6. Aguardar WordPress ──────────────────────────────────
step "Aguardando WordPress"

info "Aguardando container WordPress..."
until docker compose exec -T wordpress php -v &>/dev/null; do
    sleep 2
done
info "WordPress pronto!"

# ─── 7. Instalar WP-CLI ─────────────────────────────────────
step "Preparando WP-CLI"

info "Instalando WP-CLI no container WordPress..."
docker compose exec -T wordpress bash -c '
    if ! command -v wp &>/dev/null; then
        curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        echo "WP-CLI instalado com sucesso"
    else
        echo "WP-CLI já está presente"
    fi
'

# ─── 8. Instalar WordPress ──────────────────────────────────
step "Instalação do WordPress"

if docker compose exec -T wordpress wp core is-installed 2>/dev/null; then
    warn "WordPress já instalado — pulando"
else
    WP_URL="http://localhost:${WP_PORT:-8080}"
    WP_TITLE="${PROJECT_NAME:-WordPress Dev}"
    WP_USER="${WP_ADMIN_USER:-admin}"
    WP_PASS="${WP_ADMIN_PASSWORD:-admin}"
    WP_EMAIL="${WP_ADMIN_EMAIL:-dev@localhost.local}"

    info "Instalando WordPress em $WP_URL ..."
    docker compose exec -T wordpress wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_USER" \
        --admin_password="$WP_PASS" \
        --admin_email="$WP_EMAIL" \
        --skip-email

    info "WordPress instalado com sucesso!"
fi

# ─── 9. Instalar plugins gratuitos via WP-CLI ──────────────
step "Plugins (WordPress.org)"

install_plugin() {
    local slug=$1
    if docker compose exec -T wordpress wp plugin is-installed "$slug" 2>/dev/null; then
        info "$slug já instalado"
    else
        info "Instalando $slug..."
        docker compose exec -T wordpress wp plugin install "$slug" --activate
    fi
}

install_plugin redis-cache
install_plugin elementor
install_plugin image-optimization

# ─── 10. Elementor Pro (comercial) ─────────────────────────
step "Elementor Pro"

if [ -d plugins/pro-elements ] && [ -f plugins/pro-elements/pro-elements.php ]; then
    if docker compose exec -T wordpress wp plugin is-installed pro-elements 2>/dev/null; then
        info "pro-elements já instalado"
    else
        info "Ativando pro-elements (encontrado localmente)..."
        docker compose exec -T wordpress wp plugin activate pro-elements
    fi
else
    warn "pro-elements não encontrado em plugins/"
    warn "Para instalar:"
    warn "  1. Baixe o ZIP em https://elementor.com/my-account/"
    warn "  2. Extraia em plugins/pro-elements/"
    warn "  3. Execute: docker compose exec wordpress wp plugin activate pro-elements"
    warn "  Ou use: docker compose run --rm wpcli wp plugin install /path/to/pro-elements.zip"
fi

# Ativa a conexão com Redis
step "Redis"
docker compose exec -T wordpress wp redis enable --force 2>/dev/null && \
    info "Redis cache ativado" || true

# ─── 10. Configurar permalinks ──────────────────────────────
step "Configurações adicionais"

docker compose exec -T wordpress wp rewrite structure '/%postname%/' --quiet 2>/dev/null && \
    info "Permalink structure configurada para /%postname%/"

# ─── 11. Remover plugins e temas padrão ────────────────────
info "Removendo plugins e temas padrão..."
docker compose exec -T wordpress wp plugin delete hello akismet --quiet 2>/dev/null || true
docker compose exec -T wordpress wp theme delete twentytwentythree twentytwentytwo --quiet 2>/dev/null || true

# ─── 12. Sumário final ─────────────────────────────────────
step "Setup concluído!"

echo ""
echo "=============================================="
echo -e "  ${GREEN}✅ Ambiente pronto para desenvolvimento${NC}"
echo "=============================================="
echo ""
echo "  📍 Site:       http://localhost:${WP_PORT:-8080}"
echo "  🔐 WP Admin:   http://localhost:${WP_PORT:-8080}/wp-admin"
echo "  👤 Usuário:    ${WP_ADMIN_USER:-admin}"
echo "  🔑 Senha:      ${WP_ADMIN_PASSWORD:-admin}"
echo "  🗄️  phpMyAdmin: http://localhost:${PMA_PORT:-8081}"
echo ""
echo "  ─── Comandos úteis ───"
echo "  docker compose ps              # Status dos containers"
echo "  docker compose logs -f         # Logs em tempo real"
echo "  docker compose down            # Parar tudo"
echo "  docker compose run --rm wpcli wp ...   # WP-CLI"
echo "  bash export.sh                 # Exportar DB"
echo ""
echo "  ─── Pastas do projeto ───"
echo "  plugins/           → wp-content/plugins (apenas plugins próprios no Git)"
echo "  themes/            → wp-content/themes"
echo "=============================================="
