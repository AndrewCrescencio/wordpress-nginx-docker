FROM wordpress:latest-fpm

# ─── Extensões PHP adicionais ──────────────────────────────────
# Descomente conforme necessidade do projeto:
# RUN docker-php-ext-install bcmath pdo_mysql
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# ─── PHP config customizada ────────────────────────────────────
COPY config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# ─── Uso no docker-compose.yml ─────────────────────────────────
# Para usar este Dockerfile em vez da imagem oficial:
#
#   wordpress:
#     build:
#       context: .
#       dockerfile: docker/php/Dockerfile
#     ...
