# Projetos Elementor

Esta pasta é destinada a projetos que **utilizam apenas Elementor** — sem tema filho personalizado ou código PHP customizado relevante.

## Quando usar esta pasta

- O site é construído inteiramente via Elementor (pages, templates, popups)
- O tema ativo é um tema Elementor padrão (Hello Elementor, Astra, etc)
- Não há funções PHP customizadas no tema filho
- As únicas personalizações são via construtor visual

## Estrutura esperada

```
elementor-projects/
└── nome-do-cliente-ou-projeto/
    ├── README.md              # Informações de setup do projeto
    ├── templates/             # Templates Elementor exportados (.json)
    ├── site-settings/         # Configurações globais do site
    └── page-screenshots/      # Screenshots das páginas como referência
```

## Convenção de nomenclatura

- Use o nome do cliente ou projeto em **kebab-case**
  - Ex: `cliente-x`, `site-institucional-acme`, `landing-eventos-2026`

## Como exportar templates Elementor

1. No WP Admin, vá em **Templates → Saved Templates**
2. Selecione o template que deseja exportar
3. Clique em **Export** (formato `.json`)
4. Salve o arquivo em `elementor-projects/nome-do-projeto/templates/`

## Como documentar um projeto Elementor

Crie um `README.md` dentro da pasta do projeto com:

```markdown
# Nome do Projeto

## Descrição
Breve descrição do site e seu propósito.

## Tema ativo
- Nome e versão do tema

## Plugins essenciais (além dos padrão)
- Lista de plugins adicionais e versões

## Páginas criadas
- Home
- Sobre
- Contato
- etc.

## Configurações manuais (fora do Elementor)
- Ajustes de ACF, configurações de plugin, etc.

## URL de produção
- https://site-cliente.com.br
```

## Observações

- Esta pasta **não** passa pelo PHP CodeSniffer no CI
- Projetos aqui não exigem revisão de código PHP — apenas revisão visual
- Quando um projeto Elementor evoluir para precisar de código customizado, mova a parte PHP para `plugins/` ou `themes/` conforme o caso
