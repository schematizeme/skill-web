# Changelog — schematize-web

Formato: [Keep a Changelog]; versionamento: SemVer. Contraparte de frontend do
`schematize-go`: o que for servidor/API/dados delega ao schematize-go.

## [1.6.0] — 2026-07-06
Build/deploy destrutivo do zero (git+env) + isolamento por app (adaptado a frontend).

### Adicionado
- references/ops.md: fonte única de config/env; todo (re)deploy é build limpo do zero a partir do git+env (sem artefato/cache stale, sem editar o site publicado), preservando dados; isolamento por app (self-host: user Linux + systemd/container hardened; host gerenciado: sandbox imutável do provedor).
- Piso no CLAUDE.md; anti-padrões (deploy com build/cache stale; editar site publicado; config fora da fonte única); /web-ops estende as checagens.

## [1.5.0] — 2026-07-05
Fluxo de ambientes e deploy pelo pipeline (adaptado a frontend).

### Adicionado
- references/ops.md (frontend): fluxo dev→local→github→hml/preview→prd, nada direto no servidor/site (só via git→CI/deploy, artefato imutável); pipeline como interface única de deploy/rollback (promoção sem depender da IA); paralelo/independência quando o sistema tem múltiplos apps/serviços.
- Comando /web-ops; pisos no CLAUDE.md; anti-padrões (editar site deployado, subir direto pra prd, deploy manual fora do pipeline); qualidade.md com o fluxo; /web-load carrega ops.md.

## [1.4.0] — 2026-07-05
Todo MD gerado no archive, root limpo.

### Corrigido
- MAPA/índice saíam no root → agora `<projeto>_archive/index/` (padroes-codigo §4, MAPA.md, /web-index, build-index.mjs, CLAUDE.md, SKILL.md).

### Adicionado
- Layout canônico do archive (qualidade.md): todo MD gerado em `<projeto>_archive/<área>/`, NUNCA no root.

## [1.3.0] — 2026-07-03

### Alterado
- **Índice/MAPA exaustivo e como grafo** (§4 / §39 / `/web-index` / `MAPA.md` / `CLAUDE.md`): o índice passa a exigir **uma entrada por componente/hook/função/rota** de cada serviço/app (`nº entradas == nº unidades`). O `/web-index` **conta as declarações** e **reprova** se o índice tiver menos entradas, listando as ausentes pelo nome — chega de mapa magro (o caso "90 linhas pra 100+"). Removida a brecha do "relevante". O MAPA vira **grafo** (serviços + chamadas, Mermaid + adjacência), não lista.

## [1.2.0] — 2026-07-03

### Adicionado
- **Contenção no workspace** (§40.1 / anti-padrões §37 / `CLAUDE.md`): aplicação/repo novo nasce **dentro da pasta do projeto atual** (`./<projeto>_<contexto>/`). Veto a começar largando arquivos no root e depois **subir de diretório** (`cd ..`, `../`) pra criar repos irmãos fora, ou espalhar arquivos em `~`/`Documents`/`Downloads`/`/tmp`/Área de Trabalho. O agente **não sai da pasta do projeto** (ler ou escrever) sem o usuário pedir.

## [1.1.1] — 2026-06-27

### Adicionado
- Novo reference **`design-referencias.md`**: referências de design **além do apple.com** (Stripe, Linear, Vercel, Family, Refactoring UI…) e **método de coesão visual** (tokens + escalas + `DESIGN.md`).
- `/web-claude` passa a **mesclar** o `CLAUDE.md` em repo multi-linguagem (não sobrescreve blocos de outras skills).

## [1.1.0] — 2026-06-27

### Adicionado
- **Headers de segurança do site** (CSP imposta + CSP estrita em Report-Only, X-Content-Type-Options, Referrer-Policy, X-Frame-Options, Permissions-Policy, COOP, CORP, HSTS) — §43.3.
- **Observabilidade de front integrada ao LGTM+ da casa** (Grafana Faro + OpenTelemetry-JS → Alloy → Tempo/Loki/Prometheus/Mimir; W3C Trace Context ponta a ponta) — §49.5.
- **Convenção de nome de repositório** `<projeto>_<contexto>[_<lang>]` — §40.1.
- Comandos: **`/web-load`** (carrega à força o corpo normativo) e **`/web-claude`** (cria/atualiza o `CLAUDE.md` da raiz).

## [1.0.0] — 2026-06-20
Primeira release do **schematize-web** — padrões normativos de frontend da casa,
com foco em sites rápidos em SEO e velocidade.

### Adicionado
- Conhecimento normativo fatiado em `references/` (arquitetura/fronteira client-server,
  segurança, acessibilidade WCAG 2.2 AA, performance/Core Web Vitals, SEO + dados
  estruturados + i18n, qualidade/índice/DoD, testes, observabilidade, anti-padrões,
  stack/versões, contexto Claude Code).
- Comandos: `/web-help`, `/web-cc`, `/web-handoff`,
  `/web-qa` (a11y/CWV/e2e/visual), `/web-review`, `/web-index`.
- Scripts: `lib.sh`, `smoke-selfcheck.sh`, `check-diff.sh` (macaquices de frontend),
  `build-index.mjs` (índice de componentes/hooks), `gen-sitemap.mjs` (sitemap
  autogerado estático/dinâmico com hreflang), `archive-secret-scan.sh`, hooks de contexto.
- Assets: `CLAUDE.md`, templates (ADR/TASK/CHAT/PR/RUNBOOK/INDEX_GLOBAL/INDEX_COMPONENTS),
  `settings.claude.example.json`, CI (`ci/` com Lighthouse/axe/e2e/visual), lint
  (`lint/` eslint a11y+security+fronteiras, tsconfig strict), pre-commit (`hooks/`).
- Site `skills.schematize.me/web` (multi-idioma PT/EN/ES, AI-friendly) + instalador.

### Pisos inegociáveis cobertos
- Segredo nunca no cliente / `NEXT_PUBLIC_`; token em cookie HttpOnly, nunca localStorage;
  auth/authz decididas no servidor (§43).
- Sem `dangerouslySetInnerHTML` não sanitizado; CSP + headers (§43).
- Acessibilidade WCAG 2.2 nível AA como piso (§44).
- Core Web Vitals e budgets como contrato no CI (§45).
- SEO técnico + dados estruturados + sitemap autogerado + i18n com URL por idioma (§46/§47).
- Arquivos ≤300 linhas + doc-comment + índice como fonte da verdade (§6/§39).
- Testes "verde de verdade" (unit/componente/e2e/a11y/visual) com gate de a11y e CWV (§48).
- Archive obrigatório (§28); Q.A. plan-first (§48.7); handoff de contexto (§34.1).
- Stack só Next.js ou Astro; Node permitido só no frontend (§40).
