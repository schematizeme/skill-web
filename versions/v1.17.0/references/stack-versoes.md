# Anexo A — Versões Correntes e Thresholds (frontend)

> Parte da skill **schematize-web**. **Esta é a fonte volátil** — versões de stack e thresholds mudam. Atualize aqui (revisão trimestral) sem mexer no corpo normativo. **Verificado em: 2026-10-14**
> (números conferidos no registry do npm, em `nodejs.org/dist/index.json` e no `nodejs/Release` schedule.json nesta data). Sempre confirme o número atual (`npm show <pkg> version`, release notes oficiais, web.dev, w3.org) antes de pinar.

## Stacks (LTS / estável de produção)

| Stack | Alvo (verificado em 2026-10-14) | Notas |
|---|---|---|
| **Node.js** | **24.21.0 LTS** (Krypton) p/ produção | 22.23.3 (Jod) em manutenção (EOL 30/04/2027); **26.11.1 ainda é *Current*** — entra em LTS em **28/10/2026** (schedule oficial; suporte até 30/04/2029): hoje não vai para produção, daqui a 2 semanas é candidato. A partir do 27, um major por ano. |
| **Next.js** | **16.4.0** | Requer **Node ≥ 20**, **React 19**, Turbopack como bundler default. **Next 15 sai de suporte em 21/10/2026** (2 anos de LTS de manutenção desde 21/10/2024): **BLOQUEIO** — projeto novo nasce no 16 e projeto em 15 entra no checklist de migração (ADR) antes dessa data; depois dela, CVE novo em 15 não tem patch garantido. |
| **Astro** | **7.3.8** | Requer Node ≥ 22.12. *(Era `6.x` neste anexo até 21/08/2026 — o 7 já é o estável.)* |
| **React** | **19.3.0** | Server Components/Actions estáveis. |
| **TypeScript** | **7.0.2** — **GA, não mais RC** | O compilador *Go-native* saiu do RC. `strict: true` sempre; `erasableSyntaxOnly` + `verbatimModuleSyntax` quando o projeto quer rodar TS direto no Node sem build step. |

> **Regra:** site novo é Next.js **ou** Astro (§40.1). Pin exato no lockfile. Mudança de major exige ADR. Confirme o patch atual antes de fixar.

## Core Web Vitals — thresholds "bom" (p75 de campo, CrUX, mobile primeiro)

| Métrica | Bom | A melhorar | Ruim | Alerta sugerido (~80%) |
|---|---|---|---|---|
| **LCP** (Largest Contentful Paint) | **< 2,5 s** | 2,5–4 s | > 4 s | > 2,0 s |
| **INP** (Interaction to Next Paint) | **≤ 200 ms** | 200–500 ms | > 500 ms | > 160 ms |
| **CLS** (Cumulative Layout Shift) | **≤ 0,1** | 0,1–0,25 | > 0,25 | > 0,08 |

- **INP substituiu o FID** em março/2024 como métrica oficial de responsividade.
- Avaliado no **p75** de visitas reais (CrUX) na janela de **28 dias**; uma página só passa se **as três** passam.
- **Mobile é a referência** primária de ranking (mesmo pra resultado desktop). Otimize pro celular mediano em rede ruim.
- Fontes a reconferir: web.dev (definição de thresholds) e o relatório do PageSpeed/Search Console.

## Acessibilidade — versão vigente

| Item | Estado (jun/2026) |
|---|---|
| **WCAG vigente** | **2.2** (W3C Recommendation desde out/2023, atualizada dez/2024; ISO/IEC 40500:2025). |
| **Nível-alvo da casa** | **AA** (piso legal na maioria das jurisdições). |
| **WCAG 3.0** | Ainda **Working Draft** (final estimado ~2029) — preparar, não adotar como conformância. |
| **Contexto legal** | UE: **European Accessibility Act** em vigor desde **28/06/2025**, via EN 301 549 (alinhando-se ao WCAG 2.2 AA). EUA: DOJ/ADA referenciam WCAG 2.x AA; Seção 508 ainda em 2.0 AA. |

- Critérios novos do 2.2 que mais reprovam: **Target Size 24×24 (2.5.8)**, **Focus Not Obscured (2.4.11)**, **Dragging Movements (2.5.7)**, **Accessible Authentication (3.3.8)**, **Consistent Help (3.2.6)**, **Redundant Entry (3.3.7)** — ver §44.7.

## Ferramentas de referência (CI e qualidade)

| Função | Ferramenta sugerida |
|---|---|
| Performance/budget no CI | Lighthouse CI |
| a11y automatizado | axe-core (`@axe-core/playwright`, `jest-axe`/`vitest-axe`) |
| Teste de componente | Testing Library (+ Vitest/Jest) |
| e2e | Playwright |
| Regressão visual | Playwright snapshots / Percy / Chromatic |
| Web Vitals de campo | lib `web-vitals` + RUM |
| Sanitização | DOMPurify (server-side) |
| Lint | ESLint + `eslint-plugin-jsx-a11y` + `eslint-plugin-security` + `eslint-plugin-import` |

> Estes números **mudam**. Se a data acima estiver velha, trate este anexo como suspeito e reconfirme nas fontes oficiais antes de decidir versão ou meta.
