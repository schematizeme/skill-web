# Padrões de UI da casa — o que a geração padrão erra (app-shell, gráficos, date/modal, mobile)

> Parte da skill **schematize-web**. `design-refino.md` dá o **acabamento visual**; este dá
> os **padrões de aplicação** que a geração de front automática quase sempre entrega mal ou
> não entrega: **gráficos, menu lateral, largura fluida, date-picker e modal no padrão
> Material, e mobile de verdade utilizável**. São os maiores buracos de um front gerado —
> aqui viram norma. Números são defaults sensatos, não dogma.

## 1. App shell — header + menu lateral + conteúdo fluido (MUST em app/dashboard/admin)
- **Todo produto app-like** (dashboard, admin, painel, SaaS logado) nasce com **app shell**:
  **header** fino + **sidebar lateral** de navegação + **área de conteúdo fluida**. Landing/
  marketing usa top-nav; produto usa **sidebar**. Não entregue tela de app como página solta
  sem navegação persistente.
- Estrutura por **CSS grid**: `grid-template-columns: auto 1fr` (rail + conteúdo), header
  em `sticky top-0`. Conteúdo com **scroll próprio**, header/sidebar fixos.

## 2. Menu lateral (sidebar) (MUST quando há app shell)
- **Colapsável:** estado expandido (ícone + label) e **rail** colapsado (só ícone, com
  tooltip). Persiste a escolha (cookie/localStorage de *preferência*, não segredo).
- **Navegação real:** grupos/seções, **rota ativa destacada**, ícones do set único (§17,
  nunca emoji), teclado completo (`Tab`/setas), `aria-current="page"` no item ativo,
  landmark `<nav aria-label>`.
- **Mobile:** a sidebar vira **drawer off-canvas** (hambúrguer), com scrim, focus-trap e
  `Esc` pra fechar (mesma disciplina de modal, §6). Nunca uma sidebar fixa comendo a tela no
  celular.

## 3. Largura dinâmica / layout fluido (MUST — chega de largura quebrada)
- **Fluido com teto de legibilidade:** o conteúdo **preenche o espaço** (`1fr`, `%`, `fr`),
  mas texto corrido respeita **`max-width` ~65–75ch** (§design-refino). Nada de largura fixa
  em px que estoura em tela grande ou espreme em pequena.
- **`clamp()` para tipografia e espaço fluidos** (`font-size: clamp(1rem, .9rem + .5vw,
  1.25rem)`); **`minmax()`/`auto-fit`/`auto-fill`** em grids de cards
  (`grid-template-columns: repeat(auto-fit, minmax(min(100%, 18rem), 1fr))` — reflui sozinho).
- **Container queries** (`@container`) pro componente se adaptar ao container, não só à
  viewport. Sidebar redimensionável é opcional; se tiver, persiste a largura.
- **Nunca** `width: 1200px` cravado, `overflow-x` no body, ou layout que só funciona numa
  largura. Zero scroll horizontal (a não ser em container rolável explícito — tabela/código).

## 4. Gráficos / dataviz — INCENTIVADOS, não opcionais (SHOULD forte)
- **Regra de incentivo:** **objeto/entidade com dado quantitativo, série temporal, contagem
  ou proporção MERECE visualização** — não só tabela crua. Tem métrica/histórico/status
  agregável? entrega um **gráfico** (no dashboard e/ou no detalhe do objeto). Um sistema com
  dados e zero gráfico é entrega incompleta.
- **Biblioteca:** uma só por projeto, **leve e acessível**. Default recomendado:
  **Recharts** (React/Next, simples) ou **ECharts** (volume/interatividade alta); evite
  libs pesadas no caminho crítico — **lazy-load** o gráfico (§45, code-splitting), fora do LCP.
- **Escolha do tipo pelo dado:** série temporal → **linha/área**; comparação categórica →
  **barra**; parte-do-todo → barra empilhada (**pizza só ≤5 fatias**, nunca 3D); distribuição
  → histograma; correlação → dispersão. Sem chartjunk, sem eixo truncado enganoso.
- **Acessível e no tema:** título + descrição textual + **fallback em tabela** (não só cor —
  §44), cores dos **tokens** (dark-mode aware), `tabular-nums` nos valores, eixos legíveis,
  tooltip acessível. **Estados vazio/carregando(skeleton)/erro** também no gráfico.
- Paleta e método de escolha: ver a skill **`dataviz`** (paleta validada, formas, contraste)
  como complemento.

## 5. Date/time picker — padrão Material/Google (MUST — é um dos maiores fails)
- **Não role à mão** um picker (fonte clássica de bug/inacessibilidade). Use primitivo
  sólido: **react-day-picker** (headless, estilizável no tema) ou **MUI X Date Pickers**
  (Material exato); mobile pode cair no **`<input type="date/time">`** nativo.
- **UX Material:** grade de calendário, navegação mês/ano, **entrada por teclado E
  calendário**, **range** quando aplicável, `min`/`max`, hoje destacado, **locale via `Intl`**
  e **timezone explícito** (nunca assumir a do browser em dado que persiste).
- **Acessível:** `role="grid"` no calendário, navegação por setas, foco gerenciado, label
  associado ao input, formato claro + máscara/validação server-side.

## 6. Modais / dialogs — padrão Material/Google (MUST)
- **Primitivo acessível, nunca `div` fingindo modal:** **Radix Dialog**, **Headless UI**, ou
  **`<dialog>` nativo**. À mão dá quase sempre foco vazando e teclado quebrado.
- **Comportamento Material obrigatório:** **scrim/overlay**, **focus-trap** dentro do modal,
  **`Esc` fecha**, **foco volta ao gatilho** ao fechar, `role="dialog"` + `aria-modal` +
  `aria-labelledby`, **body sem scroll** enquanto aberto, animação enter/exit curta (§refino).
- **Responsivo:** no mobile, dialog **vira full-screen** (ou bottom-sheet) — padrão Material;
  não um cartãozinho espremido. Ação destrutiva **confirma** e o botão primário domina (§refino).
- Não empilhe modal sobre modal sem necessidade; prefira fluxo ou drawer.

## 7. Responsividade + mobile utilizável (MUST — revisão obrigatória)
- **Mobile-first de verdade:** projete e **teste em 360–390px** primeiro. `<meta viewport>`
  correto, `viewport-fit=cover` + **safe-areas** (`env(safe-area-inset-*)`) pra notch.
- **Alvos de toque ≥ 44–48px** (Material; piso WCAG é 24px §44); **sem affordance só-hover**
  (touch não tem hover — tudo acessível por tap/foco).
- **Padrões de reflow:** tabela larga → **cards** ou scroll horizontal com 1ª coluna sticky;
  multi-coluna → **empilha**; sidebar → **drawer**; ações primárias → considere **bottom-bar**.
- **Formulário no celular:** `inputmode`/`type` certos (teclado numérico etc.), input **não
  coberto pelo teclado** on-screen, label sempre visível, erro perto do campo.
- **Revisão de mobile é gate**, não "depois": passe o **checklist** abaixo antes do pronto.

## Piso (MUST)
- App-like → **app shell com sidebar** (drawer no mobile); layout **fluido** (sem largura fixa
  quebrada, sem scroll-x no body).
- **Gráfico** onde há dado agregável (lib leve, lazy, acessível, no tema).
- **Date-picker e modal** por primitivo acessível no **padrão Material** (nunca à mão/quebrado).
- **Mobile utilizável** verificado em ~360px: alvos ≥44px, sem hover-only, reflow feito,
  teclado não cobre input, zero scroll-x.
- Tudo dentro do budget de **CWV** (§45), **a11y AA** (§44) e **tokens/refino** (§design-refino).

## Checklist de reprovação (rode antes de dar o front por pronto)
- [ ] App-like tem **sidebar** (rail colapsável + drawer no mobile), rota ativa marcada, teclado ok?
- [ ] Layout **fluido** (clamp/minmax/%), texto ≤75ch, **zero scroll horizontal** no body?
- [ ] Todo dado agregável tem **gráfico** (tipo certo, lazy, tema, a11y + fallback tabela, 3 estados)?
- [ ] **Date-picker** por lib sólida, locale/timezone, teclado + calendário, acessível?
- [ ] **Modal** por primitivo (Radix/`<dialog>`): scrim, focus-trap, Esc, foco volta, full-screen no mobile?
- [ ] **Mobile em ~360px**: alvos ≥44px, sem hover-only, tabela reflui, teclado não cobre input, safe-area?
- [ ] Ícones (não emoji, §17), tokens/dark, dentro de CWV e a11y AA?

> Regra de bolso: **um front de app sem sidebar, com largura fixa, tabelão cru sem gráfico,
> date-picker/modal quebrados e ilegível no celular é o "sofrível" padrão.** Estes padrões
> existem justamente pra matar esse default — não são enfeite, são o piso de um front usável.
