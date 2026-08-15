# Refino Visual — o que separa um front polido de um amador

> Parte da skill **schematize-web**. `design-referencias.md` dá a **coesão** (tokens,
> escalas, método) — necessária, mas coesão só evita que o site pareça *quebrado*, não
> o faz parecer *desenhado*. Este arquivo é a camada **tática**: as alavancas concretas,
> com números, que transformam "renderizou" em "tem acabamento". Quando um front "sai uma
> porra" mesmo com tokens no lugar, quase sempre é **uma destas 13**. Números são
> **defaults** (ponto de partida sensato), não dogma — ajuste com intenção, não "no olho".

## Regra zero — Ícones, nunca emoji (MUST, sem exceção)

**VETADO usar emoji na estrutura do site** (nav, botões, cards, features, bullets,
títulos, empty states, "check/x", setas, badges, indicadores de status) **a menos que o usuário peça
explicitamente** (ex.: um seletor de reação, conteúdo gerado por usuário, um post que
*é sobre* emoji).

- **Use um icon set de verdade:** Lucide, Phosphor, Heroicons, Radix Icons, Tabler —
  um só por projeto. SVG inline ou sprite, `stroke`/`fill: currentColor`, `width/height`
  via token, `aria-hidden="true"` quando decorativo (ou `<title>`/`aria-label` quando
  semântico).
- **Por que emoji é reprovado:** renderiza diferente por SO/fonte (Apple ≠ Google ≠
  Windows ≠ Twemoji) — você perde o controle do visual; **não herda cor** (`currentColor`
  não pega), então quebra tema/dark/hover; **não herda peso/tamanho ótico** e desalinha
  a baseline; carrega tom infantil/casual que raramente combina com a marca; e vira ruído
  de acessibilidade (o leitor de tela fala "sorriso com olhos de coração").
- **Um icon set = uma linguagem:** mesma família, mesmo `stroke-width` (ex.: 1.5–2px),
  mesma grade (20/24px), mesmo canto. Misturar Lucide com Font Awesome com emoji é o tell
  amador nº 1 depois do espaçamento.

> Se precisar de "ícone" e não houver no set, **escolha outro conceito do mesmo set** ou
> adicione o SVG ao set — nunca tape o buraco com emoji.

---

## As 13 alavancas (falha → correção, com números)

### 1. Espaçamento generoso e **assimétrico** (o tell nº 1)
- **Falha:** tudo com o mesmo respiro apertado; seções coladas; padding uniforme por toda
  parte. Parece planilha, não página.
- **Correção:** **mais espaço ENTRE grupos do que DENTRO** deles (lei de proximidade). Ritmo
  vertical forte entre seções: **96–160px** (desktop) / **64–96px** (mobile) entre blocos
  maiores; **24–48px** dentro de um bloco. Espaço em branco **não é vazio, é o design** —
  na dúvida, dobre. Escala de espaço (4/8): `4,8,12,16,24,32,48,64,96,128,160`.
- **Piso:** nada de padding/gap fora da escala; seção "hero"/section com respiro vertical
  ≥ 96px desktop.

### 2. Hierarquia com **saltos grandes**, não tímidos
- **Falha:** h1 `24px`, h2 `20px`, corpo `16px` — tudo quase igual, nada domina, o olho não
  sabe onde pousar.
- **Correção:** contraste de tamanho **corajoso**. Hero/display **48–72px** (até 96px),
  section title **32–40px**, corpo **16–18px**. Razão modular **1.25–1.333**. Peso e cor
  também carregam hierarquia — não empilhe tudo em tamanho.
- **De-ênfase por CONTRASTE, não só por tamanho:** texto secundário fica **cinza** (`--text-muted`,
  ~60–70% do texto principal), não menor. Encolher tudo destrói a hierarquia; baixar
  contraste preserva.

### 3. Neutros fazem 90% — **um** acento, usado com avareza
- **Falha:** acento em tudo (todo botão azul, todo card com borda colorida) → nada se
  destaca; ou 5 cores competindo.
- **Correção:** paleta = **rampa de cinzas + 1 acento**. O acento marca **a UMA ação que
  importa** por tela (o CTA primário). Todo o resto é neutro. Segunda cor só pra semântica
  (danger/success/warn), nunca decorativa.
- **Cinza de verdade:** não use `#000`/`#fff` puros pra texto — **off-black** (`#0b0f19`~`#111`)
  em fundo **off-white** (`#fafafa`~`#f8f8f7`), e uma rampa com **leve tint** (cinzas com um
  toque do hue do acento) em vez de cinza dessaturado morto. Isso sozinho já eleva.

### 4. Elevação: **sombra em camadas** OU hairline — nunca pesado, nunca nada
- **Falha:** card sem borda flutuando sem separação; ou `box-shadow: 0 4px 8px #000` dura e
  cinza-suja; ou borda `1px solid #ccc` grossa e escura.
- **Correção:** dois caminhos, escolha **um** por superfície:
  - **Hairline:** `1px` de borda **de baixo contraste** (ex.: `rgba(0,0,0,.06–.1)` no claro;
    `rgba(255,255,255,.08)` no dark) + `--surface` levemente diferente do fundo.
  - **Sombra realista = múltiplas camadas** low-opacity empilhadas (ambiente + direta), não
    uma só dura. Ex.: `0 1px 2px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.06), 0 12px 32px rgba(0,0,0,.05)`.
    Sombra colorida (tint do fundo) > preto puro. Quanto mais "alto" o elemento, maior e mais
    difusa a sombra — coerência de fonte de luz.
- **No dark:** sombra quase não aparece — separe por **borda/superfície mais clara**, não por
  sombra preta.

### 5. Comprimento de linha e largura de conteúdo
- **Falha:** texto ocupando 100% de uma tela larga (`120ch`), ilegível; ou container sem
  largura máxima.
- **Correção:** corpo de texto **60–75 caracteres** por linha (`max-width: 65ch`). Container
  de página com **max-width** (`1120–1280px`) e margens laterais generosas (`≥24px` mobile).
  Conteúdo denso (docs/blog) mais estreito ainda.

### 6. Grade e alinhamento — bordas retas, nada solto
- **Falha:** elementos "quase" alinhados; ícone e texto com baselines diferentes; colunas com
  larguras arbitrárias.
- **Correção:** tudo numa **grade** (colunas consistentes, `gap` da escala). **Alinhe pela
  borda** (left-align vence center-align pra blocos de texto longos — centralizado só pra
  1–2 linhas). **Alinhamento ótico** > matemático em ícone+texto (ajuste fino de 1px quando o
  olho pede). Um container, uma largura, um gutter.

### 7. Tipografia com craft
- **Falha:** line-height default em tudo; heading grande com `line-height: 1.6` esparramado;
  fonte de sistema onde a marca pedia caráter.
- **Correção:** **line-height por tamanho** — apertado no display (**1.05–1.2**), confortável no
  corpo (**1.5–1.7**). **`letter-spacing` levemente negativo** em headings grandes (`-0.01`~`-0.03em`);
  neutro/positivo em uppercase pequeno (labels: `+0.03–0.08em`, `text-transform: uppercase`,
  `font-size: 12–13px`, peso 600). **`font-feature-settings`**/`text-rendering` ligados;
  **`font-variant-numeric: tabular-nums`** em tabelas/preços/dados. Fonte real via `next/font`
  (self-host, `font-display: swap`, sem CLS). Uma família (duas no máx.).

### 8. Raio de canto — escala e **aninhamento**
- **Falha:** `border-radius` diferente em cada componente; ou raio de fora igual ao de dentro,
  fazendo o canto interno "vazar".
- **Correção:** escala pequena de raio (`4/8/12/16` + `full` p/ pill). **Raio externo > interno**
  quando aninha (`raio_interno = raio_externo − padding`) pra cantos concêntricos. Consistência
  de raio = consistência de personalidade (soft vs. sharp) — escolha e mantenha.

### 9. Estados e affordance (o que é vivo parece vivo)
- **Falha:** botão/input sem hover/focus/active/disabled; foco removido (`outline: none` cru);
  tudo estático.
- **Correção:** **todo elemento interativo tem os 4 estados** desenhados (hover, focus-visible,
  active, disabled), com **transição ~120–200ms ease-out**. **CTA primário domina** visualmente
  (só ele preenchido com o acento); secundário é outline/ghost. Foco **sempre visível** (ring
  com offset, contrasta em claro e dark — §61). Cursor certo, `:active` com micro-deslocamento
  (`translateY(1px)`) dá tato.

### 10. Imagens e mídia com tratamento
- **Falha:** `<img>` cru, esticado, aspect-ratio variando, PNG com fundo branco batendo no
  fundo da página.
- **Correção:** **aspect-ratio consistente** (`aspect-ratio` + `object-fit: cover`), `border-radius`
  do sistema, às vezes hairline/overlay sutil pra assentar. `next/image` (dimensão, lazy, formato
  moderno, zero CLS — §45). Ilustração/screenshot com moldura consistente. Placeholder blur.

### 11. Fundos com profundidade sutil (sem gimmick)
- **Falha:** tudo no mesmo branco chapado; nada separa uma seção da outra; ou gradiente
  arco-íris/glow exagerado.
- **Correção:** alterne **`--surface` vs `--surface-subtle`** entre seções (diferença mínima),
  ou hairline divisória. Profundidade discreta: gradiente **monocromático** muito sutil, grão/
  noise leve, mesh contido, radial glow **de baixa opacidade** atrás do hero. Regra: se o efeito
  chama atenção pra si, exagerou. E não pode estourar CWV (§45).

### 12. Motion com propósito, curto
- **Falha:** animação decorativa por toda parte, longa, com bounce; ou zero feedback.
- **Correção:** motion serve **continuidade e feedback**, não enfeite. **Enter 150–250ms
  ease-out**; hover/press mais curto ainda. Prefira `transform`/`opacity` (GPU, sem layout
  thrash). Stagger sutil em listas. **`prefers-reduced-motion` sempre** desliga/reduz (§44).
  Scroll-reveal discreto (fade+8px de subida), nunca "voando da lateral".

### 13. Estados vazio/carregando/erro **desenhados** + os detalhes finais
- **Falha:** lista vazia = nada; loading = espécie de "flash"; erro = texto cru vermelho.
- **Correção:** **empty state** com ícone (do set), título curto, uma linha de copy e **uma ação**.
  **Loading = skeleton** com a forma real do conteúdo (não spinner genérico), shimmer sutil.
  **Erro** com ícone + mensagem humana + retry. E os detalhes que ninguém faz e todo mundo sente:
  **`::selection`** tematizada, **scrollbar** discreta coerente, **`caret-color`** no acento,
  **favicon/OG** caprichados, **paridade total no dark** (§60–61), `scroll-behavior: smooth` +
  `scroll-margin-top` pra âncoras não colarem no header sticky.

---

## Checklist de reprovação (rode contra seu front — "tá feio, por quê?")

Passe por esta lista **antes** de considerar o layout pronto. Cada "não" é um ponto de refino:

- [ ] **Ícone (não emoji)** em toda a estrutura? Um icon set só, `currentColor`, tamanho por token?
- [ ] Espaço **entre seções ≫ dentro** delas? Respiro ≥96px desktop entre blocos?
- [ ] Existe **um** elemento que claramente domina cada tela (hierarquia com salto grande)?
- [ ] Secundário de-enfatizado por **cor/muted**, não só encolhido?
- [ ] **Um acento** só, no CTA que importa? Resto neutro? Cinzas com tint, texto off-black?
- [ ] Elevação por **hairline OU sombra em camadas** — nunca borda grossa nem sombra dura?
- [ ] Corpo de texto **≤75ch**? Container com `max-width`?
- [ ] Tudo numa **grade**, left-aligned, bordas retas, ícone+texto alinhados oticamente?
- [ ] **Line-height por tamanho** (apertado no display), `letter-spacing` negativo em heading grande, tabular-nums em dados?
- [ ] **Raio consistente** e aninhado (externo > interno)?
- [ ] Interativos com **4 estados** + transição curta? Foco visível? CTA primário dominante?
- [ ] Imagens com **aspect-ratio + object-fit + raio** do sistema? `next/image`?
- [ ] Seções separadas por **superfície/divisória**? Profundidade sutil, sem gimmick?
- [ ] Motion **curto, com propósito, reduced-motion**?
- [ ] **Empty/loading(skeleton)/erro** desenhados? `::selection`/scrollbar/favicon/dark caprichados?

> Regra de bolso: **quase todo "front feio" é falta de espaço, hierarquia tímida, acento
> espalhado, ou emoji no lugar de ícone.** Corrija esses quatro antes de procurar efeito novo.
> Refino é **subtração e disciplina**, não mais coisa na tela. E tudo aqui cabe no budget de
> performance (§45) — acabamento que estoura CWV não é sofisticação, é regressão.
