# Refino visual: o piso técnico (o refino em si mora na schematize-design)

> Parte da skill **schematize-web**. O **refino visual** (as 13 alavancas de acabamento com números, a lista de recusas
> de "cara de IA", tipografia, cor, animação, wireframe e auditoria visual) migrou para a skill
> **`schematize-design`**: `schematize-design → references/piso-de-qualidade.md` (piso e alavancas),
> `schematize-design → references/recusas-anti-ai-slop.md` (recusas), `schematize-design → references/animacao.md`
> (movimento) e `schematize-design → references/tokens-tipografia-cor.md` (tokens). Este arquivo guarda **só o que é
> engenharia de front**: o que o código precisa garantir, independente do gosto. Carregue as duas skills ao trabalhar
> em UI.

## Fronteira

| É da schematize-design (direção visual) | É desta skill (engenharia de front) |
|---|---|
| espaço, hierarquia, acento, elevação, raio, tipo com craft, fundos, movimento com propósito, empty/erro desenhados | o que o código tem de garantir: ícone como SVG acessível, estados e foco, `prefers-reduced-motion`, zero CLS, orçamento de CWV, contraste medido, dark sem flash |
| wireframe, aprovação, auditoria visual, polimento | auditoria técnica (axe, Lighthouse, testes) em `references/testes.md` |

## Regra zero: ícones, nunca emoji (MUST, sem exceção)

**VETADO usar emoji na estrutura do site** (nav, botões, cards, features, bullets, títulos, empty states, "check/x",
setas, badges, indicadores de status) **a menos que o usuário peça explicitamente** (seletor de reação, conteúdo
gerado por usuário, um post que *é sobre* emoji).

- **Ícone é SVG inline ou sprite**, `stroke`/`fill: currentColor`, `width`/`height` por token, `aria-hidden="true"`
  quando decorativo (ou `<title>`/`aria-label` quando semântico). Botão só de ícone tem nome acessível e alvo de 44px.
- **Um icon set por projeto** (mesma família, mesmo `stroke-width`, mesma grade de 20 ou 24px). Misturar famílias, ou
  famílias com emoji, é o defeito amador número um depois do espaçamento. A escolha entre biblioteca e ícone desenhado
  por modo (app vs página de marca) é decisão de design: `schematize-design → references/icones.md`.
- **Por que emoji é reprovado (técnico):** renderiza diferente por SO e fonte; **não herda cor** (`currentColor` não
  pega), então quebra tema, dark e hover; não herda peso nem tamanho ótico e desalinha a baseline; e vira ruído de
  acessibilidade (o leitor de tela fala "sorriso com olhos de coração").
- Falta o ícone no set? Escolha outro conceito do mesmo set ou adicione o SVG ao set. Nunca tape o buraco com emoji.

## O piso técnico de UI (o código tem de garantir)

1. **Quatro estados em todo interativo:** hover, `focus-visible`, active, disabled. **Foco sempre visível** (nunca
   `outline: none` cru; anel com offset, contraste AA em claro e escuro, §44). Hover só atrás de
   `@media (hover: hover) and (pointer: fine)` (em toque o hover dispara no tap).
2. **Contraste medido, não estimado** (§44): texto 4.5:1, texto grande e componente 3:1, em **todos os temas e todos os
   estados**. Cor de acento tem dois papéis (rótulo em cima, forma contra o fundo). Método e auditor:
   `schematize-design → references/contraste.md`.
3. **Movimento dentro do orçamento (§45, §44):** só `transform` e `opacity`; `prefers-reduced-motion` respeitado **com o
   conteúdo visível** nesse ramo; nada de `opacity: 0` em CSS puro sobre conteúdo estático (estado oculto só depois que
   o JS confirma que o movimento pode rodar); sem scroll hijacking. Easing, duração e o framework de decisão:
   `schematize-design → references/animacao.md`.
4. **Zero CLS:** `width`/`height` ou `aspect-ratio` em toda imagem e mídia; `next/image` (lazy abaixo da dobra,
   `priority` só no LCP); fonte via `next/font` self-hosted com `font-display: swap`; esqueleto com a forma real do
   conteúdo para estado de carregamento (spinner genérico desloca layout).
5. **Estados vazio, carregando e erro existem** em toda lista e toda chamada: erro com
   mensagem humana e nova tentativa; o desenho deles é da `schematize-design`.
6. **Tema sem flash** (§59, `references/design-tokens.md`): tokens como fonte única, `color-scheme`, tema aplicado antes
   da primeira pintura. Detalhes de superfície do navegador (`::selection`, `caret-color`, scrollbar, `scroll-margin-top`
   para âncora sob header fixo) entram nos tokens.
7. **Imagem e mídia de verdade ou provisória marcada:** nada de imagem quebrada em produção; mídia **gerada** nunca por
   modelo Claude (regra de mídia da `schematize-design`, execução na `schematize-models`).
8. **Tudo dentro do budget de CWV (§45):** acabamento que estoura Core Web Vitals não é sofisticação, é regressão.

## Checklist técnico (rode contra o front antes de dar por pronto)

- [ ] Ícone em toda a estrutura é SVG (`currentColor`), nenhum emoji, um icon set só?
- [ ] Todo interativo tem os 4 estados, foco visível e alvo de 44px? Hover atrás de `(hover: hover)`?
- [ ] Contraste medido em todos os temas e estados (AA)?
- [ ] Movimento só em `transform`/`opacity`, com ramo de `prefers-reduced-motion` e conteúdo visível?
- [ ] Zero CLS (dimensão ou `aspect-ratio`, fonte self-hosted, esqueleto)?
- [ ] Empty, loading e erro existem e estão ligados a dado de verdade?
- [ ] Dark/tema sem flash, tokens como fonte única?
- [ ] Passou a revisão visual da `schematize-design` (`/design-polish`, `/design-audit`)?

> O refino em si é **subtração e disciplina**, e a regra de bolso (falta de espaço, hierarquia tímida, acento
> espalhado, ícone mal resolvido) vive na `schematize-design → references/piso-de-qualidade.md` §D.
