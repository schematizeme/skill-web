# schematize-web

> Padrões normativos de frontend da casa — **sites rápidos em SEO e velocidade**, i18n-ready por padrão, acessibilidade WCAG 2.2 AA, Core Web Vitals e descoberta por IA (AIO/LLMO/GEO).

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills** ([skills.schematize.me](https://skills.schematize.me)).

## Instalar

### Última versão (recomendado)

A partir de um clone do repositório:

```bash
git clone https://github.com/schematizeme/skill-web.git
cd skill-web && ./install.sh            # instala no projeto atual (diretório corrente)
# ./install.sh /caminho/do/projeto        # ou aponte para outro projeto
```

Ou baixe o `.zip` da última release e descompacte direto em `.claude/skills/`:

```bash
curl -L -o schematize-web.zip \
  https://github.com/schematizeme/skill-web/releases/latest/download/skill-web.zip
unzip schematize-web.zip -d .claude/skills/
```

### Uma versão específica

Cada versão tem três formas de obter: **(1)** um Release com `.zip` para baixar,
**(2)** uma pasta navegável em `versions/`, e **(3)** uma tag git.

| Versão | Data | Download (.zip) | Pasta navegável | Notas |
|---|---|---|---|---|
| **1.0.0** | 2026-06-20 | [release](https://github.com/schematizeme/skill-web/releases/download/v1.0.0/skill-web.zip) | [versions/v1.0.0/](versions/v1.0.0) | [CHANGELOG](CHANGELOG.md) |

```bash
# clonar uma versão exata pela tag:
git clone --branch v1.0.0 https://github.com/schematizeme/skill-web.git
```

> Todas as versões aparecem na página de **[Releases](https://github.com/schematizeme/skill-web/releases)**.

## Comandos

Todos prefixados por `web-` — **sem conflito** com as outras skills na mesma máquina.

| Comando | O que faz |
|---|---|
| `/web-cc` | comando `web-cc` |
| `/web-handoff` | comando `web-handoff` |
| `/web-help` | comando `web-help` |
| `/web-index` | comando `web-index` |
| `/web-qa` | comando `web-qa` |
| `/web-review` | comando `web-review` |

Digite `/web-help` dentro do Claude Code para ver a lista completa.

## Conteúdo da skill

- `SKILL.md` — porta de entrada e pisos inegociáveis.
- `references/` — corpo normativo fatiado por domínio (leia o que casa com a tarefa).
- `assets/` — templates (ADR/TASK/RUNBOOK/…), comandos, `CLAUDE.md`, CI, lint, hooks.
- `scripts/` — andaime de testes, índice e gestão de contexto.
- `skill.toml` — manifesto da skill (slug, nome, versão, descrições).

## Skills irmãs

- [skill-go](https://github.com/schematizeme/skill-go) — backend Go principal.
- [skill-rust](https://github.com/schematizeme/skill-rust) — backend Rust principal.
- [skill-web](https://github.com/schematizeme/skill-web) — frontend / SEO / performance.

As três podem ficar habilitadas ao mesmo tempo: os comandos são namespaced por skill
(`go-*`, `rust-*`, `web-*`).

## Licença

[MIT](LICENSE) © 2026 schematizeme.
