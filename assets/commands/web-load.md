---
description: schematize-web — carrega à força TODO o corpo normativo de frontend (arquitetura/fronteira client-server, clean code, segurança, acessibilidade, performance/CWV, SEO/i18n, testes) no contexto e passa a aplicá-lo no projeto atual como regra inegociável
---

Carregue **à força** e passe a aplicar **integralmente** os Padrões de Frontend da Casa (skill `schematize-web`) neste projeto. A partir de agora, nesta sessão, isto **não é opcional**.

1. **Leia agora, na íntegra, TODOS os arquivos** de references da skill — não trabalhe de memória, abra cada arquivo. O caminho é `.claude/skills/schematize-web/references/*.md` (instalação no projeto) ou `~/.claude/skills/schematize-web/references/*.md` (instalação global). Com destaque para:
   - `padroes-codigo.md`/`qualidade.md` — **clean code**: arquivos ≤300 linhas, micro-componentes/hooks, doc-comment, índice, DoD.
   - `arquitetura.md` — fronteira client/server, camadas, design de API de componente, estado.
   - `seguranca.md` — segredo nunca no cliente/`NEXT_PUBLIC_`, token em cookie HttpOnly, CSP + headers, XSS.
   - `acessibilidade.md` — WCAG 2.2 AA (semântica, teclado, foco, contraste, reduced-motion).
   - `performance.md` — Core Web Vitals, budgets, imagem/fonte.
   - `seo-i18n.md` + `aio-llmo-geo.md` — SEO técnico, dados estruturados, sitemap, i18n com URL por idioma; descoberta por IA.
   - `dados-estado.md`, `design-tokens.md`, `operacao-deploy.md`, `observabilidade.md`, `testes.md`, `anti-padroes.md`, `stack-versoes.md`, `contexto-claude-code.md`.

2. **Confirme ao usuário** que leu, com **1 linha por arquivo** resumindo o piso central de cada um.

3. Deste ponto em diante, **aplique estes padrões como regra inegociável** em todo componente, decisão e revisão deste projeto — fronteira client/server, clean code, segurança, acessibilidade, Core Web Vitals, SEO/i18n, testes e archive. Em conflito entre "fazer rápido" e o padrão, **o padrão vence**.

4. **Atualize o `CLAUDE.md` da raiz** do repositório com a versão atual de `assets/CLAUDE.md` da skill — **sobrescreva mesmo se já existir** (rodar não pode deixar a versão antiga). Se o `CLAUDE.md` atual tiver customização local (seções fora do template da skill), salve backup `./CLAUDE.md.bak` e reaplique as customizações por cima do template novo. Se não existir, crie. É o mesmo que o comando `/web-claude`. Confirme a versão aplicada.
