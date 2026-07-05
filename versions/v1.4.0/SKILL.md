---
name: schematize-web
metadata:
  version: 1.4.0
description: Padrões normativos de frontend da casa para sites rápidos em SEO e performance (Next.js ou Astro, TypeScript strict) — fronteira client/server explícita, segurança no servidor, acessibilidade WCAG 2.2 AA, Core Web Vitals, SEO e dados estruturados, i18n com URL por idioma, sitemap autogerado, testes de verdade (unit/componente/e2e/a11y/visual) e archive obrigatório. Use SEMPRE que for projetar, gerar, revisar ou refatorar qualquer UI, componente, página, rota de frontend, layout, estilo, App Router/RSC, server action, BFF de front, build, SEO, acessibilidade ou performance web — mesmo que o usuário não cite "padrão" e mesmo que peça só "um componentezinho" ou "uma landing rápida". Contém pisos inegociáveis (segredo nunca no bundle nem em NEXT_PUBLIC_/VITE_/PUBLIC_, token em cookie HttpOnly e nunca em localStorage, auth decidida no servidor, sem dangerouslySetInnerHTML não sanitizado, a11y AA, archive sempre) que vetam atalhos inseguros. Backend, API e banco ficam FORA do escopo e delegam ao schematize-go.
---

# Padrões de Frontend da Casa (schematize-web)

Conjunto normativo que rege como **site e interface** são projetados, construídos, testados e operados aqui — com foco declarado em **performance de SEO e de velocidade**. É a contraparte de frontend do `schematize-go`: o que for servidor/API/dados/infra de back **delega ao schematize-go**; o que for UI/página/rota de front/estilo/SEO/acessibilidade/performance é governado aqui.

**Versão:** skill `schematize-web` v1.4.0. Changelog em `CHANGELOG.md`. Versões de stack e thresholds (que mudam) ficam em `references/stack-versoes.md` (Anexo A), atualizado à parte.

## Comandos (Claude Code)

Digite `/web-help` pra ver todos. Em resumo:

| Comando | O que faz |
|---|---|
| `/web-help` | lista todos os comandos do schematize-web |
| `/web-cc` | context compact: gera context.md + checklist.md no archive e roda `/compact` |
| `/web-handoff` | gera o handoff **sem** compactar — pra fim de sessão |
| `/web-qa` | Q.A. de frontend plan-first: a11y, Core Web Vitals, e2e, regressão visual — planeja, pede aprovação, roda |
| `/web-review` | roda o gate da DoD no diff (arquivos >300, componente/função sem doc, índice, macaquices de front) |
| `/web-index` | (re)gera o índice de componentes/hooks a partir dos doc-comments |

Os comandos ficam em `assets/commands/` e são instalados em `.claude/commands/`.

## Como usar esta skill

1. Identifique o domínio da tarefa e **leia o(s) reference(s) relevante(s)** antes de produzir código ou decisão. Não trabalhe de memória — versões, thresholds e convenções estão nos arquivos (números voláteis em `references/stack-versoes.md`).
2. **Sempre** aplique os pisos inegociáveis abaixo, independente do reference carregado.
3. Se a tarefa tocar servidor/API/banco/infra de back, **carregue também o schematize-go** — este skill cobre só o frontend.
4. Ao terminar, valide contra a Definition of Done (`references/qualidade.md`) e **gere o archive**.

Mapa de references — leia o que casa com a tarefa:

| Tarefa | Reference |
|---|---|
| Fronteira client/server (RSC, route handler, server action, BFF), componentes pequenos, estado, data fetching, loading/error/empty | `references/arquitetura.md` |
| Data fetching + cache/revalidação, mutations (server actions), estado (servidor/cliente/URL), formulários com validação server-side | `references/dados-estado.md` |
| Segredo no servidor, cookies de sessão, CSP/headers, XSS, sanitização, open-redirect, CSRF, higiene de dependência, SRI | `references/seguranca.md` |
| Acessibilidade WCAG 2.2 AA: semântica, teclado, foco, contraste, motion, ARIA | `references/acessibilidade.md` |
| Performance: Core Web Vitals, budgets de bundle, imagem/fonte, code splitting, zero CLS, Lighthouse no CI | `references/performance.md` |
| SEO técnico, dados estruturados (schema.org), sitemap autogerado, **i18n-ready por padrão** (mesmo monolíngue) + multilíngue com URL por idioma/hreflang, layout de referência, OG dinâmica | `references/seo-i18n.md` |
| **Descoberta por IA: AIO/LLMO/GEO**, conteúdo extraível/citável, markup legível por máquina e IA, `llms.txt`, política de crawler de IA, E-E-A-T | `references/aio-llmo-geo.md` |
| Deploy (estático/SSR/edge), cache/CDN, ISR/revalidação, env/segredos por ambiente, feature flags, rollback, runbook | `references/operacao-deploy.md` |
| Design tokens (cor/tipo/espaço), tema e dark mode sem flash, contraste AA em todos os temas | `references/design-tokens.md` |
| **Referências de design (além do apple.com) e método de coesão visual (tokens/escalas/DESIGN.md)** | `references/design-referencias.md` |
| **Limites de código (≤300 linhas), uma função/arquivo, comentários, MAPA** | `references/padroes-codigo.md` |
| Tamanho de arquivo, doc-comment, índice de componentes/hooks, Definition of Done | `references/qualidade.md` |
| Testes "verde de verdade": unit/componente (Testing Library), e2e (Playwright), a11y (axe), regressão visual, gates no CI | `references/testes.md` |
| Observabilidade de front: captura de erro, RUM/Web Vitals, log estruturado sem PII | `references/observabilidade.md` |
| Filosofia, aplicação universal e a lista completa de anti-padrões (macaquices) de frontend | `references/anti-padroes.md` |
| Versões LTS correntes (Next/Astro/React/TS/Node) e thresholds (CWV, WCAG) | `references/stack-versoes.md` |
| Gestão de contexto em sessões longas no Claude Code (handoff, hooks) | `references/contexto-claude-code.md` |

## Pisos inegociáveis (VETADO — sem ADR de exceção)

Estes nunca são violados, nem "pra funcionar", nem "pra ir mais rápido". A lista completa com veto + caminho certo está em `references/anti-padroes.md`. Os que mais aparecem em frontend gerado às pressas:

- **Segredo nunca no cliente.** Nada de API key, secret, senha, service-role key ou token de terceiro no bundle do browser, nem em `NEXT_PUBLIC_*` / `VITE_*` / `PUBLIC_*` (esse prefixo **expõe por definição** — é "outdoor"). Toda chamada com chave secreta passa por **BFF / route handler / server action**. Detalhe em `references/seguranca.md`.
- **Token/sessão em cookie `HttpOnly` + `Secure` + `SameSite`** — **nunca** em `localStorage`/`sessionStorage` (XSS lê tudo lá).
- **Auth e autorização decididas no servidor.** `if (user.isAdmin)` no React é UX, não controle. A decisão real é server-side (route handler/middleware/server action). `tenant_id`/role vêm do token verificado, nunca de prop/query do cliente.
- **Sem `dangerouslySetInnerHTML` com conteúdo não sanitizado** (XSS). HTML de terceiro/usuário passa por sanitizador (allowlist). Sem `eval`/`new Function` com input.
- **CSP + headers de segurança** (CSP, COOP, CORP, `Referrer-Policy`, `Permissions-Policy`, `X-Content-Type-Options`, `frame-ancestors`). Open-redirect só com allowlist; CSRF mitigado.
- **Acessibilidade WCAG 2.2 nível AA é piso, não enfeite:** HTML semântico, navegação completa por teclado, foco visível e gerenciado, contraste mínimo, `prefers-reduced-motion` respeitado, alvo ≥ 24×24px. Desabilitar regra de lint de a11y/segurança é VETADO.
- **Sem `any`/`@ts-ignore`/`@ts-nocheck`** pra calar o compilador. **TypeScript strict** ligado. Erro nunca engolido (`catch {}`, `.catch(()=>{})`).
- **Estados de loading / erro / vazio sempre tratados** em todo data fetching. `fetch` em `useEffect` sem cleanup/abort, lista renderizada sem `key`, e dependência de efeito mentirosa são bugs, não estilo.
- **Teste nunca silenciado** pra passar CI (`.skip`, `test.only` esquecido, comentar `expect`, baixar threshold/budget). Conserta o código, não o teste. Gate de **a11y** e de **Core Web Vitals** no CI não se desliga "temporariamente".
- **Archive SEMPRE gerado.** Toda entrega que produz código/decisão/mudança de estado gera o `.md` de archive em `<projeto>_archive` — é parte da entrega, não extra. Pular é violação direta. Templates em `assets/`.
- **Pisos de código (`references/padroes-codigo.md`):** arquivos **≤ 300 linhas** (acima → quebrar por coesão em micro-componentes/hooks), **uma função/componente por arquivo** (função > 300 linhas é quebrada), **todo componente/hook/função com doc-comment** (motivo, comportamento esperado, entradas, saídas, efeitos), **`MAPA.md` da aplicação** atualizado no mesmo PR — em **`<projeto>_archive/index/`, nunca no root** — e **índice de componentes/hooks** regenerado (`/web-index`). **Todo MD gerado (MAPA/índice/plano/relatório/handoff) mora no archive**, root limpo (§28). Detalhe também em `references/qualidade.md`.
- **i18n-ready por padrão, mesmo monolíngue.** `<html lang>`/`og:locale`/`inLanguage` no idioma local; **zero string de UI hardcoded** (tudo em catálogo por locale desde o dia 1); formatação por `Intl`; roteamento pronto pra receber um segmento de idioma sem quebrar links. Garante SEO no idioma local agora e torna o multilíngue trivial depois. Detalhe em `references/seo-i18n.md` (§47.0).
- **Stack de site: só Next.js ou Astro.** Next.js para app/dinâmico e SSR; Astro para content-driven/estático. Outro framework exige ADR. **Node é 100% permitido — mas só no frontend** (o server-side do front é frontend; back de verdade é Go/Rust no `schematize-go`).

> Regra de bolso: se a justificativa começa com "só pra funcionar", "depois eu arrumo" ou "é mais rápido assim" e o resultado mexe em segredo, auth, acessibilidade, performance ou registro — é um anti-padrão vetado. Pare e faça certo.

## Site rápido em SEO e velocidade — o alvo do skill

Detalhe em `references/performance.md`, `references/seo-i18n.md` e `references/aio-llmo-geo.md` (descoberta por IA). O essencial:

- **Core Web Vitals como contrato** (p75 de campo, mobile primeiro): LCP, INP e CLS dentro do "bom". Budget de bundle e de métrica medidos no CI (Lighthouse/CWV) — regressão **trava o merge**.
- **Descoberta por IA (AIO/LLMO/GEO):** conteúdo no HTML servido, fatos auto-contidos e citáveis, structured data fiel (JSON-LD), `llms.txt`, feeds e política consciente de crawler de IA — pra ser **lido, entendido e citado** por assistentes e respostas generativas, não só rankeado. Sem truque escondido pra robô (cloaking é vetado).
- **Sitemap autogerado, toda vez.** Site estático → gera `sitemap.xml` varrendo as rotas/páginas; site via API/dinâmico → obtém o **inventário de páginas** (manifesto de rotas ou índice da API) e gera o sitemap a partir dele. Nunca à mão, nunca desatualizado. Scaffold em `scripts/gen-sitemap.mjs`.
- **Dados estruturados (schema.org/JSON-LD)** e SEO técnico completo (meta, Open Graph, canonical, robots) em toda página relevante.
- **i18n com URL própria por idioma** (locale em subpath, ex.: `/pt-br`, `/en-us`), **hreflang** recíproco, **metadados próprios por idioma** e **todo conteúdo traduzido** — nada de string solta hardcoded. O esquema de URL (ISO/BCP-47 vs. simplificado) é decidido por projeto; o default recomendado é ISO/BCP-47.
- **Layout de referência:** a disciplina visual do apple.com é o ponto de partida (hierarquia tipográfica forte, respiro, hero, grid, motion contido) — mas **não o único**: ver `references/design-referencias.md` (Stripe, Linear, Vercel, Family, Refactoring UI, etc.) e o **método de coesão** (tokens + escalas + `DESIGN.md`). É **princípio de layout e sistema**, não cópia de marca/asset.

## Testes — o que conta como "verde de verdade"

Detalhe completo em `references/testes.md`. O essencial:

- **Testa comportamento e conteúdo, não "renderizou".** `expect(container).toBeTruthy()` é teatro: assere texto, papel acessível (`getByRole`), estado e interação do usuário.
- **Pirâmide de front:** unit + **componente** (Testing Library, por papel/acessibilidade), **e2e** (Playwright) nos fluxos críticos, **a11y** (axe) por página/estado, e **regressão visual** (snapshot de pixel) nas telas-chave.
- **Smoke não pode ser teatro:** prova **conteúdo** (HTML servido tem o texto/elemento esperado, não só HTTP 200), tem assertion negativa (sem placeholder `{{`/`${`, sem `undefined`/`NaN` renderizado, sem erro de hidratação) e um **self-check que força falha conhecida** pra provar que o runner sabe reportar FAIL.
- **Gate de a11y e de CWV no CI:** violação de axe (sério/crítico) ou métrica fora do budget **bloqueia**, igual teste quebrado.
- **Q.A. plan-first (`/web-qa`):** toda submissão de Q.A. planeja tudo primeiro, gera um MD de passo a passo e **pede aprovação antes de executar**; aprovado, roda faseado/assistido ou de uma vez (subagents + watchdog que retoma de checkpoint; sem retry infinito). Nada roda às cegas.

## Andaime pronto (scripts e templates)

Não escreva do zero o que já está bundlado:

- `scripts/lib.sh` — helpers de teste (`test_pass`, `test_fail`, `test_skip`, `test_section`, `test_summary`, `http_call`, `assert_http_in`, `assert_body_contains`). Todo script de teste usa estes.
- `scripts/smoke-selfcheck.sh` — o meta-teste anti "verde mentiroso" (prova conteúdo + força falha conhecida).
- `scripts/gen-sitemap.mjs` — gerador de `sitemap.xml` para site estático (varre saída do build) **ou** dinâmico (lê manifesto/inventário de rotas).
- `scripts/build-index.mjs` — gera o **índice de componentes/hooks** dos doc-comments (sai 1 se achar componente/função sem contexto → trava CI).
- `scripts/check-diff.sh` — gate determinístico das macaquices de frontend no diff (segredo em `NEXT_PUBLIC_`, `dangerouslySetInnerHTML`, `any`/`@ts-ignore`, token em `localStorage`, `eslint-disable` de a11y/segurança, arquivo >300 linhas, etc.).
- `scripts/archive-secret-scan.sh` — varre os MDs do archive em busca de segredo/PII antes do commit.
- `scripts/hooks/context-monitor.mjs` + `scripts/hooks/precompact-backup.mjs` — gestão de contexto no Claude Code (handoff automático no limite). Ver `references/contexto-claude-code.md` e `assets/settings.claude.example.json`.
- `assets/ci/github-actions-ci.yml` — CI de referência com Lighthouse CI (budgets de CWV) + axe + build + gate de padrões.
- `assets/lint/eslint.frontend.cjs` (jsx-a11y + security + fronteiras de import) e `assets/lint/tsconfig.strict.json` (TS strict).
- `assets/hooks/.pre-commit-config.yaml` — pre-commit (scan de segredo + gate de diff).
- `assets/ADR.md`, `assets/TASK.md`, `assets/CHAT_ARCHIVE.md`, `assets/PR_TEMPLATE.md`, `assets/RUNBOOK.md` — templates de archive/decisão/PR.
- `assets/INDEX_GLOBAL.md` + `assets/INDEX_COMPONENTS.md` + `scripts/build-index.mjs` — índice de funcionalidades: o global (páginas/rotas/áreas) é mantido à mão; o de componentes/hooks é **gerado** dos doc-comments.
- `assets/CLAUDE.md` — arquivo "sempre on" pra colocar na **raiz do repositório**: pina estes padrões no contexto de toda tarefa, não só quando a skill dispara. Copie e ajuste `<project>`.

## Aplicação sempre-on

Esta skill é puxada quando a tarefa casa com a descrição. Para garantir que os padrões valham em **toda** interação do repo (e não só nas que disparam a skill), copie `assets/CLAUDE.md` para a raiz do projeto. Os dois mecanismos se complementam: o `CLAUDE.md` pina o resumo e aponta pra cá; a skill entrega o detalhe e o andaime. Em repositório full-stack, use **junto** com o `CLAUDE.md` do `schematize-go` — cada um governa seu lado da fronteira.
