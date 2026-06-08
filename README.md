# WordPress Starter Template

Template base para projetos WordPress com Docker. Para cada novo projeto, clone este repositório e renomeie.

**Stack:** Docker Compose • Nginx • PHP-FPM • MariaDB 10.11 • Redis • phpMyAdmin

---

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Setup rápido](#setup-rápido)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Fluxo de trabalho](#fluxo-de-trabalho)
- [Adicionar código ao projeto](#adicionar-código-ao-projeto)
  - [Criar um plugin](#criar-um-plugin)
  - [Criar um tema](#criar-um-tema)

- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Comandos úteis](#comandos-úteis)
- [CI/CD](#cicd)

---

## Pré-requisitos

| Ferramenta | Versão | Instalação |
|---|---|---|
| Docker Engine | >= 24 | [docs.docker.com/engine/install](https://docs.docker.com/engine/install/) |
| Docker Compose | >= 2.24 | Incluso no Docker Desktop |
| Git | >= 2.40 | `apt install git` / `brew install git` |

> **Windows:** Use WSL2 com Docker Desktop. Todos os scripts foram testados em Linux, macOS e WSL2.

---

## Setup rápido

```bash
# 1. Clone o repositório
git clone <repo-url>
cd wordpress-nginx-docker

# 2. Execute o script de onboarding
bash scripts/setup.sh
```

O script irá:

1. Criar `.env` a partir de `.env.example` (se não existir)
2. Subir todos os containers (`docker compose up -d`)
3. Aguardar o banco de dados ficar saudável
4. Instalar WP-CLI no container WordPress
5. Instalar o WordPress (se ainda não estiver instalado)
6. Ativar plugins essenciais (redis-cache)
7. Configurar permalinks para `/%postname%/`
8. Remover plugins e temas padrão (Hello Dolly, Akismet, Twenty Twenty-Three)

**Após o setup, acesse:** http://localhost:8080

| Acesso | URL | Credenciais |
|---|---|---|
| Site | http://localhost:8080 | — |
| WP Admin | http://localhost:8080/wp-admin | `admin` / `admin` |
| phpMyAdmin | http://localhost:8081 | — |

> Para usar portas diferentes, edite `WP_PORT` e `PMA_PORT` no `.env`.

---

## Estrutura do repositório

```
/
├── plugins/                  # Plugins do projeto
│   └── meu-plugin/           # (exemplo — crie seu plugin aqui)
├── themes/                   # Temas do projeto
│   └── meu-tema/             # (exemplo — crie seu tema aqui)
├── docker/
│   ├── nginx/
│   │   └── default.conf      # Configuração do Nginx
│   └── php/
│       └── Dockerfile        # Dockerfile de referência para PHP-FPM
├── .github/
│   └── workflows/
│       ├── lint.yml          # PHPCS em todo PR
│       ├── build-check.yml   # Valida docker-compose e .env
│       └── deploy-theme.yml  # Deploy manual (template)
├── scripts/
│   └── setup.sh              # Onboarding para novos devs
├── config/
│   └── uploads.ini           # Limites de upload do PHP
├── nginx/                    # (legado) Config anterior
├── ssl/                      # Certificados SSL para dev
├── docker-compose.yml
├── docker-compose.override.yml.example
├── .env.example
├── .editorconfig
├── .gitignore
└── README.md
```

---

## Fluxo de trabalho

1. **Crie uma branch** a partir de `master`:
   ```bash
   git checkout -b feat/nome-da-feature
   # ou
   git checkout -b fix/descricao-do-bug
   ```

2. **Desenvolva** em `plugins/` ou `themes/`
3. **Commit e push:**
   ```bash
   git add .
   git commit -m "feat: descrição clara do que foi feito"
   git push origin feat/nome-da-feature
   ```
4. **Abra um Pull Request** no GitHub
5. **Aguarde o CI** (lint + build check passarem)
6. **Code review** por pelo menos um membro do time
7. **Merge** para `master`

### Convenção de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` — nova funcionalidade
- `fix:` — correção de bug
- `chore:` — tarefas de manutenção
- `docs:` — documentação
- `refactor:` — refatoração (sem mudança de comportamento)

---

## Adicionar código ao projeto

### Criar um plugin

1. Crie a pasta em `plugins/`:
   ```bash
   mkdir -p plugins/meu-plugin
   ```

2. Crie o arquivo principal:
   ```php
   <?php
   /**
    * Plugin Name: Meu Plugin
    * Description: Descrição do que o plugin faz.
    * Version: 1.0.0
    * Author: Nome do Time
    */
   ```

3. Estrutura mínima esperada:
   ```
   plugins/meu-plugin/
   ├── meu-plugin.php          # Arquivo principal (comentário de cabeçalho)
   ├── README.md               # Documentação do plugin
   ├── src/                    # Código fonte (PSR-4)
   ├── assets/                 # CSS, JS, imagens
   └── languages/              # Arquivos de tradução (.pot, .po, .mo)
   ```

4. O plugin aparecerá em **WP Admin → Plugins** — ative-o por lá.

> **Importante:** Todo código PHP em `plugins/` é verificado pelo PHP CodeSniffer com WordPress Coding Standards nos PRs.

---

### Criar um tema

1. Crie a pasta em `themes/`:
   ```bash
   mkdir -p themes/meu-tema
   ```

2. Crie os arquivos obrigatórios:
   - `style.css` (comentário de cabeçalho do tema)
   - `index.php`
   - `functions.php`

3. Estrutura mínima esperada:
   ```
   themes/meu-tema/
   ├── style.css               # Comentário de cabeçalho (obrigatório)
   ├── index.php               # Template principal
   ├── functions.php           # Funções do tema
   ├── screenshot.png          # Screenshot (1200x900)
   ├── templates/              # Templates customizados
   ├── assets/                 # CSS, JS, imagens
   └── languages/              # Traduções
   ```

4. Ative o tema em **WP Admin → Aparência → Temas**.

---

## Variáveis de ambiente

Todas as variáveis estão documentadas em `.env.example`:

| Variável | Padrão | Descrição |
|---|---|---|
| `WP_PORT` | `8080` | Porta local do WordPress |
| `WP_DEBUG` | `true` | Habilita WP_DEBUG no WordPress |
| `MARIADB_DATABASE` | `wordpress` | Nome do banco de dados |
| `MARIADB_USER` | `wp_user` | Usuário do banco |
| `MARIADB_PASSWORD` | `wp_password` | Senha do banco |
| `MARIADB_ROOT_PASSWORD` | `root_password` | Senha root do MariaDB |
| `PMA_PORT` | `8081` | Porta local do phpMyAdmin |
| `PROJECT_NAME` | `Meu Projeto WordPress` | Título do site |
| `WP_ADMIN_USER` | `admin` | Usuário admin do WordPress |
| `WP_ADMIN_PASSWORD` | `admin` | Senha do admin |
| `WP_ADMIN_EMAIL` | `dev@localhost.local` | Email do admin |

---

## Comandos úteis

```bash
# Gerenciamento dos containers
docker compose up -d           # Iniciar todos os serviços
docker compose down            # Parar e remover containers
docker compose restart wordpress  # Reiniciar apenas o WordPress
docker compose ps              # Status dos containers
docker compose logs -f         # Logs de todos os serviços
docker compose logs -f nginx   # Logs apenas do Nginx

# WP-CLI (executando comandos no container)
docker compose exec wordpress wp plugin list
docker compose exec wordpress wp user list
docker compose exec wordpress wp db export -

# Acesso ao banco
docker compose exec db mariadb -u wp_user -p wordpress

# Acesso ao shell do container
docker compose exec wordpress bash

# Exportar banco de dados
bash export.sh

# phpMyAdmin (iniciar manualmente)
docker compose --profile dev up -d phpmyadmin
```

---

## CI/CD

### Lint (`.github/workflows/lint.yml`)
- Executa em todo PR que modifica `plugins/` ou `themes/`
- Roda PHP CodeSniffer com WordPress Coding Standards
- Ignora `vendor/` e `node_modules/`

### Build Check (`.github/workflows/build-check.yml`)
- Valida que `docker-compose.yml` é sintaticamente válido
- Verifica se `.env.example` tem todas as variáveis com valores padrão

### Deploy (`.github/workflows/deploy-theme.yml`)
- Workflow manual (`workflow_dispatch`) — template para deploy via rsync
- Permite escolher tipo (theme/plugin), slug e ambiente (staging/production)
- **Requer configuração de secrets no GitHub** (SSH_PRIVATE_KEY, DEPLOY_HOST, etc)

---

## Troubleshooting

### "Error establishing a database connection"
O banco pode não ter terminado a inicialização. Aguarde e tente novamente:
```bash
docker compose restart wordpress
```

### Porta 8080 já está em uso
Edite `WP_PORT` no `.env` para uma porta livre e reinicie:
```bash
docker compose up -d
```

### Permissão negada ao acessar wp-content
Os volumes montados (`plugins/`, `themes/`) usam o usuário do container (www-data). Em caso de problemas de permissão:
```bash
docker compose exec wordpress chown -R www-data:www-data /var/www/html/wp-content
```
