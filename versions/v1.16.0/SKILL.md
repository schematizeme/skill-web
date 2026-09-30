---
name: schematize-web
metadata:
  version: 1.16.0
description: Padrões normativos de frontend da casa para sites rápidos em SEO e performance (Next.js ou Astro, TypeScript strict): fronteira client/server explícita, segurança no servidor, acessibilidade WCAG 2.2 AA, Core Web Vitals, SEO e dados estruturados, i18n com URL por idioma, sitemap autogerado, refino visual (ícones-não-emoji, espaço, hierarquia, elevação), padrões de UI (app-shell, largura fluida, gráficos, date-picker/modal, mobile utilizável), testes de verdade (unit/componente/e2e/a11y/visual) e archive. Use SEMPRE que for projetar, gerar, revisar ou refatorar UI, componente, página, rota, layout, estilo, App Router/RSC, server action, BFF de front, build, SEO, acessibilidade ou performance web — mesmo que peça só "um componentezinho". Pisos: segredo nunca no bundle nem em NEXT_PUBLIC_/VITE_/PUBLIC_; token em cookie HttpOnly, nunca em localStorage; auth no servidor; sem HTML não sanitizado; a11y AA; preview é sink (efeito externo não sai de não-prd); archive sempre. Backend/API/banco: skill do rol.
---

# Padrões de Frontend da Casa (schematize-web)

Conjunto normativo que rege como **site e interface** são projetados, construídos, testados e operados aqui — com foco declarado em **performance de SEO e de velocidade**. É a contraparte de frontend da skill de backend do projeto: o que for servidor/API/dados/infra de back **delega à skill de backend do projeto**; o que for UI/página/rota de front/estilo/SEO/acessibilidade/performance é governado aqui.

**Versão:** skill `schematize-web` v1.16.0. Changelog em `CHANGELOG.md`. Versões de stack e thresholds (que mudam) ficam em `references/stack-versoes.md` (Anexo A), atualizado à parte.

## Comandos (Claude Code)

Digite `/web-help` pra ver todos. Em resumo:

| Comando | O que faz |
|---|---|
| `/web-help` | lista todos os comandos do schematize-web |
| `/web-cc` | context compact: gera context.md + checklist.md no archive e roda `/compact` |
| `/web-handoff` | gera o handoff **sem** compactar — pra fim de sessão |
| `/web-qa` | Q.A. de frontend plan-first: a11y, Core Web Vitals, e2e, regressão visual — planeja, pede aprovação, roda |
| `/web-review` | roda o gate da DoD no diff (tamanho em camadas: 750 bloqueia / >300 úteis flagueia, componente/função sem doc, índice, macaquices de front) |
| `/web-index` | (re)gera o índice de componentes/hooks a partir dos doc-comments |
| `/web-ops` | verifica o fluxo de ambientes/preview, o deploy só pelo pipeline (nada direto no site) e, em multi-app, o build paralelo/independência |
| `/web-load` | carrega à força TODO o corpo normativo de frontend no contexto e passa a aplicá-lo como regra inegociável |
| `/web-claude` | cria ou ATUALIZA o `CLAUDE.md` da raiz do repo com a versão atual da skill (faz backup se houver customização local) |
| `/web-iam` | força/audita/scaffolda o IAM no cliente (front de auth próprio em `auth.<domain>`, fluxos login/2FA/passkey, view de dispositivos, logout irreversível) |

Os comandos ficam em `assets/commands/` e são instalados em `.claude/commands/`.

## Como usar esta skill

1. Identifique o domínio da tarefa e **leia o(s) reference(s) relevante(s)** antes de produzir código ou decisão. Não trabalhe de memória — versões, thresholds e convenções estão nos arquivos (números voláteis em `references/stack-versoes.md`).
2. **Sempre** aplique os pisos inegociáveis abaixo, independente do reference carregado.
3. Se a tarefa tocar servidor/API/banco/infra de back, **carregue também a skill da linguagem de backend do projeto (rol: go/rust/elixir/csharp/zig/ruby)** — este skill cobre só o frontend.
4. Ao terminar, valide contra a Definition of Done (`references/qualidade.md`) e **gere o archive**.

Mapa de references — leia o que casa com a tarefa:

| Tarefa | Reference |
|---|---|
| Fronteira client/server (RSC, route handler, server action, BFF), componentes pequenos, estado, data fetching, loading/error/empty | `references/arquitetura.md` |
| Data fetching + cache/revalidação, mutations (server actions), estado (servidor/cliente/URL), formulários com validação server-side | `references/dados-estado.md` |
| Segredo no servidor, cookies de sessão, CSP/headers, XSS, sanitização, open-redirect, CSRF, higiene de dependência, SRI, **envio de e-mail/efeito externo fora de prd (preview = NÃO-produção, sink por default, rate-limit no endpoint público)** | `references/seguranca.md` |
| **IAM no cliente/front:** front de auth próprio (`auth.<domain>`), OIDC/OAuth2.1 + PKCE, onboarding/2FA, seletor de método, passkey/WebAuthn no browser, nudge de email secundário (detecção de provedor + tooltip), view de dispositivos, logout irreversível, token em cookie (nunca localStorage), authz é UX/enforcement server-side | `references/iam.md` |
| Acessibilidade WCAG 2.2 AA: semântica, teclado, foco, contraste, motion, ARIA | `references/acessibilidade.md` |
| Performance: Core Web Vitals, budgets de bundle, imagem/fonte, code splitting, zero CLS, Lighthouse no CI | `references/performance.md` |
| SEO técnico, dados estruturados (schema.org), sitemap autogerado, **i18n-ready por padrão** (mesmo monolíngue) + multilíngue com URL por idioma/hreflang, layout de referência, OG dinâmica | `references/seo-i18n.md` |
| **Descoberta por IA: AIO/LLMO/GEO**, conteúdo extraível/citável, markup legível por máquina e IA, `llms.txt`, política de crawler de IA, E-E-A-T | `references/aio-llmo-geo.md` |
| Deploy (estático/SSR/edge), cache/CDN, ISR/revalidação, env/segredos por ambiente, feature flags, rollback, runbook | `references/operacao-deploy.md` |
| **Ambientes/ops: fluxo dev→local→github→hml/preview→prd (nada direto no site/servidor), deploy só pelo pipeline (interface única, promoção sem depender da IA), build paralelo/independência em multi-app** | `references/ops.md` |
| Design tokens (cor/tipo/espaço), tema e dark mode sem flash, contraste AA em todos os temas | `references/design-tokens.md` |
| **Referências de design (além do apple.com) e método de coesão visual (tokens/escalas/DESIGN.md)** | `references/design-referencias.md` |
| **Refino visual: ícones-não-emoji + 13 alavancas (espaço/hierarquia/acento/elevação/tipo/estados) + checklist de reprovação** | `references/design-refino.md` |
| **Padrões de UI (o que a geração padrão erra): app-shell + menu lateral, largura fluida, gráficos incentivados, date-picker/modal Material, mobile utilizável (gate)** | `references/ui-padroes.md` |
| **Limites de código (teto 750/arquivo, ~500 úteis + flag em >300 úteis), uma função/componente por arquivo, comentários, MAPA** | `references/padroes-codigo.md` |
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
- **Pisos de código (`references/padroes-codigo.md`):** tamanho de arquivo **em camadas** — teto **DURO de 750 linhas** (~250 comentário + ~500 código útil) que **bloqueia** (acima → quebrar por coesão em micro-componentes/hooks) e **flag em > 300 linhas de código útil** que **não bloqueia mas sempre sinaliza** (componente/função extensa vira dívida pra rever; ~400 úteis em observabilidade), **uma função/componente por arquivo**, **todo componente/hook/função com doc-comment** (motivo, comportamento esperado, entradas, saídas, efeitos), **`MAPA.md` da aplicação** atualizado no mesmo PR — em **`<projeto>_archive/index/`, nunca no root** — e **índice de componentes/hooks** regenerado (`/web-index`). **Todo MD gerado (MAPA/índice/plano/relatório/handoff) mora no archive**, root limpo (§28). Detalhe também em `references/qualidade.md`.
- **i18n-ready por padrão, mesmo monolíngue.** `<html lang>`/`og:locale`/`inLanguage` no idioma local; **zero string de UI hardcoded** (tudo em catálogo por locale desde o dia 1); formatação por `Intl`; roteamento pronto pra receber um segmento de idioma sem quebrar links. Garante SEO no idioma local agora e torna o multilíngue trivial depois. Detalhe em `references/seo-i18n.md` (§47.0).
- **Stack de site: só Next.js ou Astro.** Next.js para app/dinâmico e SSR; Astro para content-driven/estático. Outro framework exige ADR. **Node é 100% permitido — mas só no frontend** (o server-side do front é frontend; back de verdade é Go/Rust na skill de backend do projeto).
- **Fluxo de ambientes e deploy pelo pipeline.** Toda mudança segue **dev local → teste local → GitHub → hml/preview → prd** (preview por PR é o "hml por mudança"); **VETADO editar direto no site/servidor deployado** (build no ar é imutável por edição manual, recebe só artefato do git com commit SHA). Deploy/rollback/config passam pelo **pipeline de CI/CD** — a interface única; nada de deploy manual ad-hoc, e a promoção hml→prd tem que ser operável pelo usuário **sem depender da IA**. Em multi-app, build/subida é **paralela** (`nproc`) e **independência é invariante** (falha no paralelo = corrigir a independência é prioridade máxima). Detalhe em `references/ops.md`.
- **Fonte única de config/env + build/deploy destrutivo do zero + isolamento por app.** A config parte de **uma fonte única de env** (self-host: `/<app>/.env` global; host gerenciado: env vars do projeto no provedor) — nada espalhado fora dela, segredo nunca no bundle. **Todo (re)deploy é build LIMPO do zero a partir de git + env** — sem artefato/cache stale, sem editar o site já publicado — recriando um build determinístico e reprodutível, mas **preservando os dados** (CMS/banco/uploads nunca zerados por um redeploy). **Isolamento por app:** self-host = user Linux + systemd/container hardened por app (multi-app: isolamento por usuário, nunca `root`); host gerenciado = a sandbox imutável do provedor. Detalhe em `references/ops.md` (§28.3, §28.4).
- **IAM por desenho no cliente — front de auth próprio, controle server-side.** O auth tem **front próprio, app à parte** (`<projeto>_authfront` em **`auth.<domain>`**); **VETADO** embutir login/2FA no bundle do site principal. O cliente **delega por OIDC/OAuth2.1 + PKCE** (code trocado por token no servidor, `client_secret` nunca no bundle). **Usuário nunca loga pelo ID interno** (email/telefone são identificadores verificados; **nudge de email secundário** com detecção de provedor + tooltip "i" acessível). **≥2 fatores** com 2º forte obrigatório: **seletor de método** + **passkey/WebAuthn** (`navigator.credentials`, feature-detect + fallback). **Token só em cookie `HttpOnly`+`Secure`+`SameSite`, nunca em `localStorage`.** **View de dispositivos** (remover/"sair de todos"); **sessão 7d/90d**; **botão "Sair" → revoke server-side irreversível** (não basta apagar cookie). **Nenhuma decisão de authz no cliente** (`can()`/`isAdmin` só pinta a UI) — **enforcement, validação de token e kill de sessão são server-side**. Detalhe em `references/iam.md`; audit/scaffold por `/web-iam`; backend/ReBAC/migração na skill de backend do projeto + `/eng-iam`.

- **Efeito externo NUNCA sai de não-produção — e `preview` NÃO é produção.** Toda **server action / route handler / BFF** que dispara e-mail (contato, newsletter, convite, **reset de senha**, **magic link**, notificação), SMS, push, webhook de terceiro ou cobrança segue o guard da normativa (`schematize-engineering` → `references/efeitos-externos.md`): **provider resolvido no servidor por ambiente**, **default = SINK** (Mailpit/log) fora de `prd`, **guard deny-by-default DENTRO do provider** (destinatário fora do domínio de teste + `env != prd` → **erro**, nunca warning) e **cap por execução** com abort. Chave corretamente server-side **não basta** — o piso aqui é o **ENVIO**: **preview/branch deploy (Vercel/Netlify/Cloudflare Pages) é NÃO-PRODUÇÃO** e é onde mais escapa e-mail real, justamente porque "parece prd" (mesmo build, envs herdadas do projeto, mesma chave). Discrimine por **`VERCEL_ENV=production|preview|development`** (Netlify `CONTEXT`, CF Pages pelo branch) — **VETADO `NODE_ENV` sozinho**, que é `production` também no build de preview (o erro clássico). Envs de **Preview** e **Development** apontam pro **sink**; a **chave de produção do provedor existe só no escopo Production** — preview com credencial de envio de prd é **incidente**. **Fail-closed:** ambiente ilegível ⇒ assume **não-prd**. **Endpoint público de envio** (form de contato/newsletter) é **bomba de e-mail de graça** e relay de spam: **rate-limit por IP + por destinatário**, cap global por janela, **anti-bot** (Turnstile/honeypot verificados no servidor), **double opt-in** em newsletter e **destinatário NUNCA vindo do corpo da requisição** (é fixo no servidor — contato vai pra caixa da casa). Endereço sintético (fixture, seed, persona, e2e, screenshot visual) só no **domínio de teste em rota nula** (`test.<domain>`/`.test`/`.invalid`/`.example`); **VETADO** `@gmail.com`, domínio de terceiro e e-mail de pessoa real (inclusive o seu). **Por quê:** bounce/complaint em massa **queima IP e domínio**, derruba o transacional de **produção** (inclusive o **OTP de login**) e custa semanas de warm-up — com utilidade **zero**. Detalhe em `references/seguranca.md` (§43.8); anti-padrão na §37 (item 55).
- **Orquestrador não desenvolve; subagent barato executa** (`schematize-engineering` → `references/orquestracao.md` §9): o principal só planeja/decompõe/despacha/revisa; toda ação onerosa vira micro-tasks; subagents em `sonnet` por padrão (falhou → mesmo subagent corrige, até 2 rodadas → re-decompõe → só então `opus`, com motivo no checkpoint). No **overdev**, cada item do checklist é executado por subagent `sonnet` e revisado pelo principal.

> Regra de bolso: se a justificativa começa com "só pra funcionar", "depois eu arrumo" ou "é mais rápido assim" e o resultado mexe em segredo, auth, acessibilidade, performance ou registro — é um anti-padrão vetado. Pare e faça certo.

## Site rápido em SEO e velocidade — o alvo do skill

Detalhe em `references/performance.md`, `references/seo-i18n.md` e `references/aio-llmo-geo.md` (descoberta por IA). O essencial:

- **Core Web Vitals como contrato** (p75 de campo, mobile primeiro): LCP, INP e CLS dentro do "bom". Budget de bundle e de métrica medidos no CI (Lighthouse/CWV) — regressão **trava o merge**.
- **Descoberta por IA (AIO/LLMO/GEO):** conteúdo no HTML servido, fatos auto-contidos e citáveis, structured data fiel (JSON-LD), `llms.txt`, feeds e política consciente de crawler de IA — pra ser **lido, entendido e citado** por assistentes e respostas generativas, não só rankeado. Sem truque escondido pra robô (cloaking é vetado).
- **Sitemap autogerado, toda vez.** Site estático → gera `sitemap.xml` varrendo as rotas/páginas; site via API/dinâmico → obtém o **inventário de páginas** (manifesto de rotas ou índice da API) e gera o sitemap a partir dele. Nunca à mão, nunca desatualizado. Scaffold em `scripts/gen-sitemap.mjs`.
- **Dados estruturados (schema.org/JSON-LD)** e SEO técnico completo (meta, Open Graph, canonical, robots) em toda página relevante.
- **i18n com URL própria por idioma** (locale em subpath, ex.: `/pt-br`, `/en-us`), **hreflang** recíproco, **metadados próprios por idioma** e **todo conteúdo traduzido** — nada de string solta hardcoded. O esquema de URL (ISO/BCP-47 vs. simplificado) é decidido por projeto; o default recomendado é ISO/BCP-47.
- **Layout de referência:** a disciplina visual do apple.com é o ponto de partida (hierarquia tipográfica forte, respiro, hero, grid, motion contido) — mas **não o único**: ver `references/design-referencias.md` (Stripe, Linear, Vercel, Family, Refactoring UI, etc.) e o **método de coesão** (tokens + escalas + `DESIGN.md`). É **princípio de layout e sistema**, não cópia de marca/asset.
- **Refino visual (o que faz parecer desenhado):** coesão por tokens evita o site *quebrado*, mas não basta pra parecer *profissional*. `references/design-refino.md` é a camada tática — **regra zero: ícones, nunca emoji** (a menos que o usuário peça) + **13 alavancas** com números (espaço generoso/assimétrico, hierarquia com salto grande, **um** acento em neutros com tint, elevação por hairline ou sombra em camadas, linha ≤75ch, grade, tipo com craft, raio aninhado, 4 estados por interativo, imagens tratadas, empty/loading/erro desenhados) + **checklist de reprovação**. Rode antes de dar o layout por pronto.
- **Padrões de UI que a geração padrão erra (`references/ui-padroes.md`):** produto app-like nasce com **app shell + menu lateral** (rail colapsável, **drawer no mobile**) e **largura fluida** (`clamp`/`minmax`/`%`, ≤75ch, **zero scroll-x no body** — nada de largura fixa quebrada). **Gráfico é incentivado** em todo objeto/entidade com dado agregável (lib leve/lazy, no tema, acessível com fallback tabela). **Date-picker e modal no padrão Material/Google por primitivo acessível** (react-day-picker/MUI X; Radix Dialog/`<dialog>`) — nunca à mão: modal com scrim/focus-trap/`Esc`/foco-de-volta/**full-screen no mobile**. **Mobile utilizável é gate** (~360px, alvos ≥44px, sem hover-only, tabela reflui, teclado não cobre input). É o antídoto pro front "sofrível" padrão.

## Testes — o que conta como "verde de verdade"

Detalhe completo em `references/testes.md`. O essencial:

- **Testa comportamento e conteúdo, não "renderizou".** `expect(container).toBeTruthy()` é teatro: assere texto, papel acessível (`getByRole`), estado e interação do usuário.
- **Pirâmide de front:** unit + **componente** (Testing Library, por papel/acessibilidade), **e2e** (Playwright) nos fluxos críticos, **a11y** (axe) por página/estado, e **regressão visual** (snapshot de pixel) nas telas-chave.
- **Smoke não pode ser teatro:** prova **conteúdo** (HTML servido tem o texto/elemento esperado, não só HTTP 200), tem assertion negativa (sem placeholder `{{`/`${`, sem `undefined`/`NaN` renderizado, sem erro de hidratação) e um **self-check que força falha conhecida** pra provar que o runner sabe reportar FAIL.
- **Gate de a11y e de CWV no CI:** violação de axe (sério/crítico) ou métrica fora do budget **bloqueia**, igual teste quebrado.
- **Q.A. plan-first (`/web-qa`):** toda submissão de Q.A. planeja tudo primeiro, gera um MD de passo a passo e **pede aprovação antes de executar**; aprovado, roda faseado/assistido ou de uma vez (subagents em `sonnet` por default — o principal só planeja/revisa; `opus` só após falha, ver `schematize-engineering` → `references/orquestracao.md` §9 — + watchdog que retoma de checkpoint; sem retry infinito). Nada roda às cegas.

## Andaime pronto (scripts e templates)

Não escreva do zero o que já está bundlado:

- `scripts/lib.sh` — helpers de teste (`test_pass`, `test_fail`, `test_skip`, `test_section`, `test_summary`, `http_call`, `assert_http_in`, `assert_body_contains`). Todo script de teste usa estes.
- `scripts/smoke-selfcheck.sh` — o meta-teste anti "verde mentiroso" (prova conteúdo + força falha conhecida).
- `scripts/gen-sitemap.mjs` — gerador de `sitemap.xml` para site estático (varre saída do build) **ou** dinâmico (lê manifesto/inventário de rotas).
- `scripts/build-index.mjs` — gera o **índice de componentes/hooks** dos doc-comments (sai 1 se achar componente/função sem contexto → trava CI).
- `scripts/check-diff.sh` — gate determinístico das macaquices de frontend no diff (segredo em `NEXT_PUBLIC_`, `dangerouslySetInnerHTML`, `any`/`@ts-ignore`, token em `localStorage`, `eslint-disable` de a11y/segurança, tamanho de arquivo em camadas — 750 bloqueia / >300 úteis flagueia, etc.).
- `scripts/archive-secret-scan.sh` — varre os MDs do archive em busca de segredo/PII antes do commit.
- `scripts/hooks/context-monitor.mjs` + `scripts/hooks/precompact-backup.mjs` — gestão de contexto no Claude Code (handoff automático no limite). Ver `references/contexto-claude-code.md` e `assets/settings.claude.example.json`.
- `assets/ci/github-actions-ci.yml` — CI de referência com Lighthouse CI (budgets de CWV) + axe + build + gate de padrões.
- `assets/lint/eslint.config.mjs` — **flat config** (ESLint 9): jsx-a11y + security + react + hooks + fronteiras de import. *(Substituiu o `eslint.frontend.cjs`, que estava em formato eslintrc com cabeçalho mandando usá-lo como flat config — não rodava — e declarava `react/no-danger` sem o plugin, o que **abortava** o ESLint.)* E `assets/lint/tsconfig.strict.json` (TS strict).
- `assets/hooks/.pre-commit-config.yaml` — pre-commit (scan de segredo + gate de diff).
- `assets/ADR.md`, `assets/TASK.md`, `assets/CHAT_ARCHIVE.md`, `assets/PR_TEMPLATE.md`, `assets/RUNBOOK.md` — templates de archive/decisão/PR.
- `assets/INDEX_GLOBAL.md` + `assets/INDEX_COMPONENTS.md` + `scripts/build-index.mjs` — índice de funcionalidades: o global (páginas/rotas/áreas) é mantido à mão; o de componentes/hooks é **gerado** dos doc-comments.
- `assets/CLAUDE.md` — arquivo "sempre on" pra colocar na **raiz do repositório**: pina estes padrões no contexto de toda tarefa, não só quando a skill dispara. Copie e ajuste `<project>`.

## Aplicação sempre-on

Esta skill é puxada quando a tarefa casa com a descrição. Para garantir que os padrões valham em **toda** interação do repo (e não só nas que disparam a skill), copie `assets/CLAUDE.md` para a raiz do projeto. Os dois mecanismos se complementam: o `CLAUDE.md` pina o resumo e aponta pra cá; a skill entrega o detalhe e o andaime. Em repositório full-stack, use **junto** com o `CLAUDE.md` da skill de backend do projeto — cada um governa seu lado da fronteira.

## Relação com as outras skills (as fronteiras, nos dois sentidos)

O frontend é o ponto onde mais coisa se encontra. Estas fronteiras são **bilaterais**: a irmã já
aponta para cá, e aqui está o que desta skill vale lá.

- **`schematize-engineering`** — a **BASE** agnóstica. Herda e não afrouxa: DoD (§35), archive
  (§28), índice/MAPA (§39), segurança, IAM, observabilidade, cadeia de suprimentos, e o fluxo
  (scan/plan/refactor/overdev/auditoria) — no laço do overdev cada item é executado por subagent `sonnet` e revisado pelo principal (`schematize-engineering` → `references/orquestracao.md` §9). **A escolha do backend é dela, não desta skill:** o rol
  sancionado é **Go, Rust, Elixir, C#, Zig e Ruby**, por fit + ADR (`references/linguagens.md`).
  Esta skill governa o **frontend**; quando precisar nomear "o backend", diga *a linguagem do rol
  escolhida no ADR do projeto* — não uma delas por default.
- **`schematize-seo`** — a **fronteira mais confundida do catálogo**. A `schematize-seo` é dona da
  **estratégia**: intenção de busca, keywords, topic clusters, canibalização entre os domínios da
  casa, hreflang recíproco, AIO/LLMO/GEO, medição. Esta skill é dona da **implementação**: onde o
  `metadata`/`<head>` é gerado (§46.1), como o JSON-LD entra na página (§46.2), como o sitemap é
  **autogerado** (§46.3), `canonical`/`robots` (§46.4) e o roteamento por idioma (§47).
  Regra prática: **"o que a página deve dizer e por quê" é seo; "onde o atributo é escrito" é web.**
  Decisão de canonical/hreflang **nunca** se toma só no código — sai da `schematize-seo`.
- **`schematize-qa`** — a disciplina de teste. O §48 desta skill é o **recorte de frontend**
  (componente, e2e, a11y, regressão visual); a pirâmide, o "verde de verdade", flaky, cobertura e
  o fluxo plan-first moram lá.
- **`schematize-pentest`** — segurança ofensiva. XSS, CSP, CSRF, `postMessage`, clickjacking e
  vazamento por client-side são testados por ela; o §43 daqui é o piso que ela cobra.
- **`schematize-mobile`** — **webview e PWA**. Quando o app nativo embute uma tela desta stack, o
  piso de token e CSP daqui **viaja junto**: o webview NÃO ganha desconto — token continua em
  cookie `HttpOnly` (nunca em `localStorage`, nunca em bridge JS), CSP continua valendo, e o
  login segue no navegador do sistema, não numa WebView (é a regra de OAuth de app público da
  `schematize-mobile`). O contrário também vale: fluxo de auth que o app abre no navegador é
  renderizado por esta skill.
- **`schematize-desktop`** — **Electron/Tauri**, o lugar onde **XSS vira RCE local**. Uma tela
  desta stack empacotada num cliente nativo deixa de ter só o sandbox do browser: se o processo
  de render tem ponte para o sistema de arquivos ou para `exec`, uma injeção de HTML vira execução
  na máquina do usuário. Piso conjunto: `contextIsolation` ligado e `nodeIntegration` desligado
  (Electron) / allowlist mínima de comandos (Tauri), CSP sem `unsafe-inline`, **zero**
  `dangerouslySetInnerHTML` não sanitizado, e nenhum segredo no bundle — o cliente nativo é
  distribuído, então "segredo no bundle" ali é segredo publicado.
- **`schematize-institutional`** — o **inventário de páginas** e as **páginas legais** que um site
  de empresa precisa ter. A fronteira: a `schematize-institutional` diz *quais páginas existem e o
  que cada uma prova*; esta skill as **constrói** (templates, a11y, CWV, i18n) e **gera** o
  `sitemap.xml`/`robots.txt` a partir daquele inventário — **autogerados** (§46.3), nunca à mão,
  que é MUST aqui e na `schematize-seo`.
