---
description: schematize-web — lista todos os comandos disponíveis e o que cada um faz
---

Mostre ao usuário a lista de comandos do conjunto **schematize-web**, em formato
de tabela legível, exatamente com este conteúdo (ajuste se houver comandos novos
instalados em `.claude/commands/`):

| Comando | O que faz |
|---|---|
| `/web-help` | Lista todos os comandos do schematize-web (este). |
| `/web-load` | **Carrega à força TODO o corpo normativo de frontend** (arquitetura, clean code, segurança, acessibilidade, Core Web Vitals, SEO/i18n, testes) no contexto e passa a aplicá-lo no projeto como regra inegociável. |
| `/web-claude` | Cria ou **atualiza (sobrescreve)** o `CLAUDE.md` da raiz com a versão atual da skill (backup se houver customização local). |
| `/web-cc` | Context compact: gera `context.md` + `checklist.md` em `<projeto>_archive/context/` e roda `/compact`. |
| `/web-handoff` | Gera o handoff (`context.md` + `checklist.md`) **sem** compactar — ideal pra fim de sessão ou troca de tarefa. |
| `/web-qa` | Q.A. de frontend plan-first: a11y (axe), Core Web Vitals, e2e (Playwright), regressão visual — planeja tudo, pede aprovação, e roda faseado/assistido ou de uma vez. |
| `/web-review` | Roda o gate da Definition of Done e dos anti-padrões (§35, §37): arquivos >300 linhas, componente/hook sem doc-comment, índice desatualizado, macaquices de segurança/a11y/perf. |
| `/web-index` | (Re)gera o índice de componentes/hooks (§39) a partir dos doc-comments. |

Depois da tabela, diga em uma linha que o detalhe normativo está na skill
`schematize-web` (referências em `references/`) e que o site é `skills.schematize.me/web`.
Se a tarefa for de servidor/API/dados, lembre que isso é escopo do `schematize-go`.
