# Changelog — schematize-web

Formato: [Keep a Changelog]; versionamento: SemVer. Contraparte de frontend do
`schematize-go`: o que for servidor/API/dados delega ao schematize-go.

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
