# Descoberta por IA (AIO/LLMO/GEO) — recorte de IMPLEMENTAÇÃO

> **PONTEIRO.** A **estratégia** de descoberta por IA é da **`schematize-seo`**
> (`references/aio-llmo-geo.md`, 311 linhas): o que torna um fato citável, entidade e E-E-A-T,
> política de crawler de IA, `llms.txt`, medição de citação, e a aplicação aos domínios da casa.
> Este arquivo era **quase literal** ao dela — até a "regra de bolso" final era a mesma palavra por
> palavra (achado da Classe F da vistoria de 2026-08-21). Duas cópias da mesma estratégia divergem;
> uma delas em silêncio.
>
> Aqui fica **só o que é implementação de frontend** — o que muda no código, não na estratégia.

## O que o frontend precisa entregar (e onde isso é implementado)

| Requisito da estratégia | Onde se implementa nesta skill |
|---|---|
| **Conteúdo no HTML servido** — crawler de IA que não executa JS só vê o que veio no HTML; conteúdo pós-hidratação é invisível para boa parte deles | fronteira client/server (§40.2): o conteúdo citável nasce em **Server Component**, nunca depende de `useEffect` |
| **Resposta direta perto do topo**, uma intenção por página | estrutura de heading e ordem do DOM (§44 semântica) — o que vem primeiro no HTML é o que é recortado |
| **Dados estruturados válidos** | §46.2 (JSON-LD por página) — e **sem** os tipos mortos (`FAQPage`, `HowTo`, `SearchAction`) |
| **Metadados por página** (title, description, OG) | §46.1 (`metadata`/`generateMetadata` no App Router) |
| **`llms.txt`** (SHOULD — nenhum crawler grande adotou) | §46.3, junto do sitemap: **gerado**, nunca à mão |
| **Velocidade** (extração falha em página lenta) | §45 (Core Web Vitals) — thresholds no anexo volátil |

> **Regra de bolso (a mesma da `schematize-seo`, e por isso citada, não recopiada):** se o fato
> importante da página **não está no HTML servido, perto do topo, em texto**, ele não é citável —
> por buscador nem por IA.

