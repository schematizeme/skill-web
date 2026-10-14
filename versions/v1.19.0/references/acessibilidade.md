# Acessibilidade — WCAG 2.2 nível AA (piso, não enfeite)

> Parte da skill **schematize-web**. Acessibilidade é **requisito**, não melhoria opcional: além de ser o certo, é exigência legal em vários mercados (na UE, o European Accessibility Act está em vigor desde 28/06/2025, referenciando WCAG via EN 301 549). O alvo da casa é **WCAG 2.2 nível AA**. O número/versão vigente fica em `references/stack-versoes.md`.

## Índice
- 44. Acessibilidade
  - 44.1 HTML semântico primeiro
  - 44.2 Teclado e foco
  - 44.3 Contraste e visão
  - 44.4 Movimento e mídia
  - 44.5 ARIA — só quando o HTML não dá conta
  - 44.6 Formulários e erros
  - 44.7 Novidades do WCAG 2.2 que mais falham

---

## 44. Acessibilidade

**Princípio (POUR):** o conteúdo precisa ser **Perceptível, Operável, Compreensível e Robusto**. Nível AA é o piso legal e o alvo de toda página.

### 44.1 HTML semântico primeiro

**MUST**
- **Elemento certo pra cada papel.** `<button>` pra ação, `<a href>` pra navegação, `<nav>`/`<main>`/`<header>`/`<footer>`/`<h1>`–`<h6>` pra estrutura. `<div onClick>` que finge ser botão é VETADO — não recebe foco, teclado nem leitor de tela de graça.
- **Uma `<h1>` por página**, hierarquia de headings sem pular nível (a árvore de headings é como o leitor de tela navega).
- **Imagem informativa tem `alt` descritivo**; imagem decorativa tem `alt=""` (vazio, intencional). Ícone clicável tem nome acessível (`aria-label` ou texto visualmente oculto).
- **Idioma declarado** (`<html lang>`), trocando por idioma quando a página é traduzida (liga com i18n, §47).

### 44.2 Teclado e foco

**MUST**
- **Tudo operável por teclado.** Todo controle interativo é alcançável por `Tab` e acionável por `Enter`/`Espaço`. Sem armadilha de foco (entra e não sai). Modal prende o foco **dentro** dela e devolve ao gatilho ao fechar.
- **Foco visível e gerenciado.** Indicador de foco claro (nunca `outline: none` sem substituto). Ao abrir modal/drawer/menu, o foco vai pra dentro; ao fechar, volta. Navegação por rota (SPA) move o foco pro novo conteúdo/`<h1>`.
- **Ordem de foco lógica**, seguindo a leitura. `tabindex` positivo é VETADO (quebra a ordem natural); use só `0` e `-1`.
- **"Pular pra o conteúdo"** (skip link) no topo de páginas com navegação longa.

### 44.3 Contraste e visão

**MUST**
- **Contraste mínimo AA:** texto normal ≥ **4.5:1**, texto grande (≥ 24px, ou ≥ 18.66px bold) ≥ **3:1**, componentes de UI e estados (borda de input, foco) ≥ **3:1**.
- **Não comunicar só por cor.** Erro não é "fica vermelho" e pronto — tem ícone/texto. Link no meio do texto se distingue além da cor.
- **Zoom/reflow:** layout funciona até **200% de zoom** e em viewport estreito sem scroll horizontal (reflow). Tamanhos em unidades relativas (`rem`), respeitando o tamanho de fonte do usuário.

### 44.4 Movimento e mídia

**MUST**
- **`prefers-reduced-motion` respeitado.** Animações, parallax e auto-play de transição são reduzidos/desligados quando o usuário pede. (Liga com o motion contido do layout de referência — §46.)
- Sem conteúdo que pisca acima do limiar de fotossensibilidade.
- Vídeo/áudio: legendas pra vídeo com fala; controles operáveis por teclado; nada de auto-play com som.

### 44.5 ARIA — só quando o HTML não dá conta

**MUST**
- **Primeira regra do ARIA: não use ARIA se um elemento HTML nativo já faz o trabalho.** `role="button"` num `<div>` é pior que um `<button>`.
- ARIA correto e completo quando necessário (widget custom: combobox, tabs, disclosure) — `aria-expanded`, `aria-controls`, `aria-current`, `aria-live` pra regiões dinâmicas, estados sincronizados com o real.
- **`aria-label`/`aria-labelledby`** dão nome a controles sem texto visível. Toast/erro assíncrono anuncia via `aria-live`.

**VETADO**
- ARIA "decorativo" ou contraditório (`aria-hidden` num elemento focável; `role` que mente sobre o que o elemento faz). ARIA errado é pior que ausente.

### 44.6 Formulários e erros

**MUST**
- **Todo input tem `<label>` associado** (não placeholder no lugar de label). Agrupar com `<fieldset>`/`<legend>` quando fizer sentido.
- **Erro de validação é programático e textual:** ligado ao campo (`aria-describedby`), anunciado, com instrução de correção — não só borda vermelha. Foco vai pro primeiro campo com erro.
- **Autocomplete** apropriado (`autocomplete="email"`, etc.) e **não bloquear colar senha** (liga com WCAG 2.2 Accessible Authentication).

### 44.7 Novidades do WCAG 2.2 que mais falham (atenção redobrada)

Estas entraram no 2.2 e são as que mais reprovam sites que já passavam no 2.1:
- **Alvo mínimo 24×24px (2.5.8 Target Size, AA).** Botões/links/ícones clicáveis têm área de toque ≥ 24×24 CSS px (com exceções de espaçamento). Mira pequena reprova.
- **Foco não obscurecido (2.4.11, AA).** O elemento com foco não pode ficar escondido atrás de header/cookie banner/chat fixo. Use `scroll-padding-top` ou gerencie o scroll no foco.
- **Movimentos de arrastar (2.5.7, AA).** Toda função com drag tem alternativa por clique simples (a menos que arrastar seja essencial).
- **Autenticação acessível (3.3.8, AA).** Não exigir teste cognitivo (resolver puzzle, transcrever) nem bloquear gerenciador de senha/colar.
- **Ajuda consistente (3.2.6, A)** e **Entrada redundante (3.3.7, A):** ajuda no mesmo lugar entre páginas; não pedir de novo dado já fornecido no mesmo fluxo.

---

## Como provar (liga com testes, §48)

- **axe** (automatizado) por página e por estado dinâmico no CI — violação `serious`/`critical` **bloqueia** (§48). Cobre ~30–40% dos critérios.
- **Manual obrigatório** pro resto: navegar a página **só com teclado**, rodar um leitor de tela (VoiceOver/NVDA/TalkBack) nos fluxos críticos, conferir contraste e zoom 200%.
- A11y é **gate na Definition of Done** (§35) — não é "a gente vê depois".

> Acessibilidade não é uma camada que se adiciona no fim. Nasce no HTML semântico e no foco. Se você precisou de muito ARIA, provavelmente usou o elemento errado.
