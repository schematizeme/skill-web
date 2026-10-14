# Runbook — <site / app de frontend>

> Front crítico (checkout, login, páginas de alto tráfego/SEO) tem runbook (§26.1).
> Atualize quando um incidente recorrer.

## Visão geral
- O que o front serve, donos, oncall, contato de escalação.
- Hospedagem/edge (Vercel/Netlify/CDN), domínios, locales servidos.

## Diagnóstico de falhas comuns
| Sintoma | Causa provável | Como confirmar | Ação |
|---|---|---|---|
| LCP/INP regrediu em produção | bundle/3rd-party novo, imagem sem otimizar | RUM/CrUX, Lighthouse | reverter, lazy-load, otimizar |
| erro de hidratação | markup server≠client, data não-determinística | console/RUM, reproduzir | alinhar render, `suppressHydrationWarning` só onde correto |
| 5xx no BFF/route handler | upstream fora, env ausente | logs do edge/server | failover, corrigir env, circuit breaker |
| queda de tráfego orgânico | sitemap/hreflang/canonical quebrado, noindex acidental | Search Console, robots | corrigir meta/sitemap, resubmeter |

## Dashboards
- <RUM/Web Vitals (p75 LCP/INP/CLS por rota e device)>
- <erros de front por release; taxa de hidratação>
- <Search Console / cobertura de indexação>

## Comandos úteis
```bash
# build de produção, preview local, regenerar sitemap, rodar Lighthouse
npm run build && npm run start
node scripts/gen-sitemap.mjs --base "$SITE_BASE_URL" --out ./out > ./out/sitemap.xml
```

## Rollback
Passo a passo para reverter o deploy (promover release anterior no edge). Healthcheck
de página crítica + smoke de conteúdo pós-deploy antes de liberar tráfego (§21.1).

## Contatos
- Oncall:
- Escalação:
