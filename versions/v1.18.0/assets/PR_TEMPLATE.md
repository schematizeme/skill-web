## O que muda
<resumo objetivo. Alvo: ≤ 400 linhas alteradas (§24).>

## Por quê
<motivação / ticket>

## Como testei
- [ ] unit + componente (Testing Library) passam, testando conteúdo/comportamento
- [ ] e2e (Playwright) nos fluxos críticos
- [ ] smoke com asserção de conteúdo + self-check (sem "verde mentiroso")
- [ ] a11y (axe) sem violação séria/crítica
- [ ] Core Web Vitals dentro do budget (Lighthouse CI) — mobile primeiro
- [ ] regressão visual revisada (diff de pixels aprovado à mão)

## Checklist de padrões
- [ ] Nenhum anti-padrão vetado (§37) no diff
- [ ] Segredo nunca no cliente / `NEXT_PUBLIC_`; token em cookie HttpOnly
- [ ] Auth/authz decididas no servidor; `dangerouslySetInnerHTML` só sanitizado
- [ ] CSP + headers de segurança presentes/atualizados
- [ ] Estados loading/erro/vazio tratados em todo data fetching
- [ ] SEO/metadados/JSON-LD/hreflang/sitemap atualizados (se aplicável)
- [ ] Índice de componentes/hooks atualizado (§39)
- [ ] Archive (chat/task) gerado e commitado (§28)
- [ ] ADR criado (se decisão arquitetural ou desvio)
- [ ] CODEOWNERS revisou

## Notas para o reviewer
<pontos de atenção, riscos, telas afetadas>
