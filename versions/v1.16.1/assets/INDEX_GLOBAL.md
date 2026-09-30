# Índice Global do Frontend — <projeto>

> **Fonte da verdade** do que existe e onde (§39). Consulte ANTES de criar algo
> (anti-duplicação). Atualizado no MESMO PR que muda funcionalidade.
> Local: `<projeto>_archive/index/INDEX_GLOBAL.md`. Última atualização: <data>.

## Apps / pacotes

| App/Pacote | O que é | Framework | Owner |
|---|---|---|---|
| web | site público (marketing + app) | Next.js | squad-x |
| ui | design system / componentes compartilhados | React + TS | squad-x |
| ... | ... | ... | ... |

## Páginas / rotas

> Rota → o que faz → tipo de render → locales → SEO.

| Rota | O que faz | Render | Locales | SEO/JSON-LD |
|---|---|---|---|---|
| `/[locale]` | home / hero | RSC estático | pt-br, en-us, es | Organization + WebSite |
| `/[locale]/precos` | planos | RSC + ISR | pt-br, en-us, es | Product/Offer |
| `/[locale]/blog/[slug]` | artigo | RSC + ISR | pt-br, en-us, es | Article + Breadcrumb |
| ... | ... | ... | ... | ... |

## Fronteira client/server

> Onde mora a lógica de servidor do front (§41): route handlers, server actions, BFF.

| Recurso | Tipo | O que faz | Segredo? |
|---|---|---|---|
| `app/api/contact/route.ts` | route handler | recebe form, fala com CRM | sim (server-only) |
| `app/actions/subscribe.ts` | server action | newsletter | sim (server-only) |
| ... | ... | ... | ... |

## Áreas transversais
- Design tokens / tema: `<onde>`
- i18n (dicionários, esquema de URL): `<onde>` — esquema: ISO/BCP-47 (`/pt-br`) | simplificado (`/br`)
- Observabilidade (erro/RUM): `<onde>`
- Geração de sitemap: `scripts/gen-sitemap.mjs`

## Links de verdade
- Componentes/hooks: `INDEX_COMPONENTS.md` (gerado)
- Budgets de CWV / Lighthouse: `/lighthouserc.*`
- ADRs: `/docs/adr/`
