#!/bin/bash

set -e

# Carrega variáveis do .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

_now=$(date +"%Y_%m_%d_%H%M")
_db_file="dumps/db_$_now.sql"
_uploads_dir="dumps/uploads_$_now"

mkdir -p dumps

# ─── Exportar banco de dados ───────────────────────────────────
echo "📦 Exportando banco de dados..."

docker compose exec db sh -c \
  "exec mariadb-dump \"\$MARIADB_DATABASE\" -uroot -p\"\$MARIADB_ROOT_PASSWORD\"" \
  | grep -v "Warning: Using a password" > $_db_file

echo "✅ Banco salvo em: $_db_file"

# ─── Exportar uploads (mídia) ─────────────────────────────────
echo "🖼️  Exportando uploads..."

docker cp wp-wordpress:/var/www/html/wp-content/uploads $_uploads_dir 2>/dev/null \
  && echo "✅ Uploads salvos em: $_uploads_dir" \
  || echo "⚠️  Nenhum upload encontrado (normal em instalação nova)"

# ─── Resumo ───────────────────────────────────────────────────
echo ""
echo "📋 Exportação concluída:"
echo "   Banco:   $_db_file"
echo "   Uploads: $_uploads_dir"
echo ""
echo "💡 Para entregar ao cliente, compacte a pasta dumps/:"
echo "   zip -r cliente_$_now.zip $_db_file $_uploads_dir themes/ plugins/"
