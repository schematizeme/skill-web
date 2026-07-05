# Referências de Design e Coesão Visual

> Parte da skill **schematize-web**. O alvo do skill é **site rápido em SEO e velocidade** — mas rápido e feio não vende. Aqui: **de onde tirar referência** (além do apple.com) e **como manter coesão visual** por design (documentada, não por gosto). Os tokens concretos estão em `references/design-tokens.md`.

## Filosofia

- **Coesão > novidade.** Um site bonito é **consistente**: mesmo ritmo de espaço, mesma escala de tipografia, mesma paleta, mesmo movimento — página a página. Inconsistência é o que faz parecer amador, não a falta de "efeito".
- **Referência é calibração, não cópia.** Estude o *porquê* (hierarquia, respiro, contraste, timing), não o pixel. Marca é da casa; disciplina é emprestada.
- **Menos, melhor.** Uma família tipográfica (duas no máximo), um acento, motion contido. Restrição é o que dá elegância — e é de graça em performance (§45).

## Referências (além do apple.com)

Curadoria por eixo. Use 2–3 por projeto como "norte", não todas.

- **Produto/SaaS com rigor:** [Stripe](https://stripe.com), [Linear](https://linear.app), [Vercel](https://vercel.com), [Retool](https://retool.com), [Height](https://height.app). Tipografia forte, grid disciplinado, dark elegante.
- **Craft/detalhe de interação:** [Family](https://family.co), [Arc](https://arc.net), [Things](https://culturedcode.com/things/), [Raycast](https://raycast.com). Microinteração e polish.
- **Editorial/tipográfico:** [Readymag showcases], [Minimalissimo](https://minimalissimo.com), [Kottke], sites de estúdio (Instrument, Locomotive, Active Theory) — hierarquia e respiro.
- **Galerias/curadoria** (varrer padrões, não copiar): [Godly](https://godly.website), [Land-book](https://land-book.com), [Mobbin](https://mobbin.com) (fluxos reais de apps), [SavimadeWebsites], [Refactoring UI](https://refactoringui.com) (o livro-base de heurística visual).
- **Autores/aprendizado:** [Rauno Freiberg](https://rauno.me) (UI craft), [Emil Kowalski](https://emilkowal.ski) (animação de UI), [Josh Comeau](https://joshwcomeau.com) (CSS/UX), [Adam Argyle](https://nerdy.dev), [web.dev](https://web.dev) (patterns performáticos).
- **Sistemas de design públicos** (como documentar): [Polaris (Shopify)](https://polaris.shopify.com), [Primer (GitHub)](https://primer.style), [Material 3](https://m3.material.io), [Atlassian](https://atlassian.design), [Base Web (Uber)](https://baseweb.design).

## Como manter coesão (o método, documentado)

Coesão não é sorte — é **tokens + escalas + regras**, escritos num lugar só:

1. **Design tokens como fonte única** (ver `design-tokens.md`): cor, tipografia, espaço, raio, sombra, z-index, **motion** (duração/easing) — nomes **semânticos** (`--color-surface`, `--space-4`), não valores soltos no componente. Um token muda, o site inteiro acompanha.
2. **Escala tipográfica modular** (ex.: 1.20–1.25 de razão): um conjunto fixo de tamanhos/pesos/line-heights. Proibido tamanho "no olho" fora da escala.
3. **Escala de espaço (grid 4/8px):** todo padding/margin/gap sai de uma escala (`4,8,12,16,24,32,48,64…`). Respiro consistente é 80% da elegância.
4. **Sistema de cor semântico + contraste AA:** paleta enxuta (neutros + 1 acento), papéis (`surface`/`text`/`muted`/`accent`/`danger`) e estados; contraste WCAG AA obrigatório (§44). Dark e light derivam dos mesmos papéis.
5. **Motion tokenizado:** durações e easings fixos (`--ease-out`, `--dur-fast`), movimento com propósito (feedback/continuidade), sempre com `prefers-reduced-motion` (§44).
6. **Documente num design system do projeto:** um `DESIGN.md` (ou página `/styleguide`) que mostra tokens, escala, componentes e do/don't. É o `INDEX` visual — consulte **antes** de criar tela nova, pra não divergir. Alimenta a coesão do mesmo jeito que o índice de componentes alimenta o código (§39).

## Piso (MUST)

- **Tokens são a fonte da verdade visual** — nada de hex/px mágico no componente; use o token.
- **Nada fora das escalas** (tipografia, espaço) sem token novo justificado.
- **Contraste AA** e **reduced-motion** sempre (§44).
- **Um `DESIGN.md`/styleguide** existe e é atualizado quando um token/padrão muda (mesma disciplina do índice, §39).

> Bonito **e** rápido: toda referência aqui é compatível com o budget de performance (§45). Efeito que estoura CWV não é sofisticação, é regressão.
