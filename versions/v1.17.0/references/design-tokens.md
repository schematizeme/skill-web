# Design Tokens, Tema e Dark Mode

> Parte da skill **schematize-web**. Disciplina de sistema visual: tokens como
> fonte única de cor/tipo/espaço, temas (incl. dark mode) sem quebrar contraste, e
> a ligação com acessibilidade (§44) e o layout de referência (§48b).

## Índice
- 59. Tokens como fonte única
- 60. Tema e dark mode
- 61. Contraste e acessibilidade do tema

---

## 59. Tokens como fonte única

**MUST**
- **Valores visuais vêm de tokens, não de literais espalhados.** Cor, tipografia
  (família/escala/peso), espaçamento, raio, sombra, breakpoint e duração de motion
  são definidos **uma vez** (CSS custom properties / arquivo de tokens) e
  consumidos por referência. Nada de `#3b82f6`/`14px` cravado no componente.
- **Escala intencional e pequena** (§48b): poucos tamanhos de tipo e de espaço,
  numa escala nomeada (`--space-2`, `--text-lg`), não números mágicos arbitrários.
- **Tokens semânticos sobre primitivos:** a UI consome `--color-surface`,
  `--color-text`, `--color-accent` (semânticos), que **referenciam** primitivos
  (`--blue-600`). Trocar tema = remapear semânticos, sem tocar componente.

**SHOULD**
- Tokens versionados e documentados (o "design system" mínimo). Se houver
  ferramenta (Style Dictionary/Tailwind theme), ela gera a partir da mesma fonte.

**VETADO**
- Cor/tamanho hardcoded fora do sistema (vira inconsistência e impede tema).
- Dois sistemas de cor concorrentes (token + literal) no mesmo projeto.

---

## 60. Tema e dark mode

**MUST**
- **Tema implementado por troca de tokens semânticos** (atributo `data-theme` /
  classe na raiz que remapeia as custom properties), não por estilos duplicados
  por componente.
- **Respeitar `prefers-color-scheme`** como default; se houver toggle, **persistir
  a escolha** (cookie/localStorage de preferência — preferência **não** é segredo)
  e aplicá-la **sem flash** (FOUC/“flash of wrong theme”): definir o tema antes da
  primeira pintura (script inline mínimo no `<head>` ou render no servidor pela
  preferência).
- **`color-scheme` declarado** (`<meta name="color-scheme">` / CSS `color-scheme`)
  pra que controles nativos (scrollbar, inputs) sigam o tema.

**SHOULD**
- Imagens/ilustrações com variante por tema quando necessário (`<picture>` +
  `prefers-color-scheme`). `theme-color` por esquema pra UI do browser.

**VETADO**
- Dark mode que só inverte cor e quebra contraste (§61). Flash de tema errado por
  decidir o tema só depois da hidratação.

---

## 61. Contraste e acessibilidade do tema

**MUST**
- **Contraste AA vale em TODOS os temas** (§44.3): texto ≥ 4.5:1, UI/estados ≥ 3:1
  — verificado no claro **e** no escuro. Token novo passa pelo gate de contraste.
- **Foco visível em todo tema** (§44.2): o indicador de foco contrasta no claro e
  no escuro; nada de foco que “some” no dark.
- **Não comunicar só por cor** (§44.3) em nenhum tema; estado tem ícone/texto além
  da cor.

**SHOULD**
- Teste de regressão visual cobre os temas (claro/escuro) nas telas-chave (§48.5).
- `prefers-contrast`/alto contraste considerado quando o público exigir.

> Regra de bolso: **um sistema de tokens, temas como remapeamento.** Se trocar de
> tema exige editar componente, ou se o dark mode reprova contraste, o sistema
> visual falhou — e a11y (§44) não é negociável em tema nenhum.
