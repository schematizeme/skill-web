---
description: Q.A. de frontend plan-first — a11y, Core Web Vitals, e2e, regressão visual; planeja, aprova, roda
argument-hint: "[escopo: smoke|a11y|cwv|e2e|visual|all|...]"
---

Conduza o fluxo de **Q.A. de frontend plan-first** (§48.7). NÃO execute nada antes de aprovar.

## Fase 1 — Planejar (sem executar)
Levante o escopo a partir de $ARGUMENTS (ou pergunte se vazio): modos a rodar
(smoke/unit/componente/e2e/a11y/cwv/visual/lighthouse), ambiente alvo (preview/staging),
páginas/rotas/locales e estados (loading/erro/vazio) afetados, viewports (mobile primeiro),
ordem, dependências (build pronto? servidor de preview no ar?) e riscos.

## Fase 2 — MD do plano
Escreva `<projeto>_archive/qa/<ts>-<contexto>.md` com cada passo: objetivo, comando
exato, ambiente/URL alvo, viewport, resultado esperado e critério de pass/fail. Para
a11y, liste páginas/estados a varrer com axe (alvo: zero violação séria/crítica). Para
CWV, liste as URLs e os budgets (LCP/INP/CLS) que o Lighthouse CI vai cobrar. Para visual,
liste as telas e o baseline. Aponte o relatório/artefato que cada passo gera.

## Fase 3 — Aprovação
Apresente o plano e **peça aprovação explícita**. Sem "ok", nada roda. Aprovação
parcial é válida e vira o escopo efetivo.

## Fase 4 — Executar (após aprovado)
Pergunte a modalidade:
- **Faseado e assistido** — roda por fase (ex.: build → smoke → a11y → e2e → cwv →
  visual), pausa entre fases, mostra parcial. Default quando há atualização de baseline
  visual ou ambiente sensível.
- **De uma vez (autônomo)** — paraleliza categorias independentes (subagents do Claude
  Code) e usa watchdog que retoma de checkpoint até concluir. Condição de parada explícita
  (tudo verde OU falha bloqueante escala pro humano); sem retry infinito.

Regras: atualização de baseline de regressão visual só com revisão humana do diff de pixels
(nunca "aceitar tudo" cego). a11y e CWV são **gate**: violação séria/crítica de axe ou métrica
fora do budget reprova a fase. Autônomo só em preview/staging por default. O plano aprovado é o
contrato — subagents/watchdog aceleram o como, não dispensam o que foi autorizado.
