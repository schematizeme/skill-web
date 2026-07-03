---
description: (Re)gera o índice de componentes/hooks (§39) a partir dos doc-comments
argument-hint: "[dir de origem, ex: src]"
---

Atualize o **índice de funcionalidades** (§39) — **fonte da verdade** do front e base do MAPA (§4). **Exaustivo**: **uma entrada por** componente/hook/função/rota, **com grafo**. Enumera, não resume.

## 1. Enumere e CONTE

Descubra **todas** as unidades do alvo `${ARGUMENTS:-src}` — componentes, hooks, funções utilitárias, rotas/páginas e providers (públicos e privados). Conte (ripgrep, ou AST):

- **Componentes:** `rg -n 'function [A-Z]\w*|const [A-Z]\w*\s*=\s*(\(|function|React|memo|forwardRef)'`
- **Hooks:** `rg -n '(export\s+)?(function|const)\s+use[A-Z]\w*'`
- **Rotas/páginas:** arquivos `page.tsx`/`route.ts`/`layout.tsx`/`+page`/`pages/**`.
- **Funções util:** `rg -n '(export\s+)?(async\s+)?function |const \w+\s*=\s*(async\s*)?\('`

Guarde **N = total de unidades** por app/pacote (faça para **cada** app/área, não só o que tocou).

## 2. Uma entrada por unidade (sem "relevante")

Para **cada** unidade, uma linha em `<projeto>_archive/index/INDEX_COMPONENTS.md`:
`nome | o quê | onde é usado | usa (out) | usado por (in) | props/efeitos | arquivo:linha`.
Fonte: `scripts/build-index.mjs` se existir; senão, dos doc-comments (§6). Nada de fora por "não ser relevante".

## 3. Construa o GRAFO (não é lista)

- **Macro** → `INDEX_GLOBAL.md`: `mermaid flowchart` de **rotas → páginas → componentes** e o **consumo de APIs/BFF**.
- **Componentes** → `INDEX_COMPONENTS.md` e `MAPA.md` (§5): `mermaid flowchart` de quem **renderiza/usa** quem **+** adjacência textual (`A -> B`). Cada componente/hook é um nó.

## 4. Concilie a COMPLETUDE (gate duro)

- Conte as entradas (**M**) vs **N**, por app/pacote. **Se M < N → FALHE**: liste as ausentes **pelo nome** e volte ao passo 2 até `M == N`. "90 linhas pra 100+ componentes" é **reprovado aqui**.
- `build-index.mjs` código 1 = unidade sem doc-comment (§6): corrija **na origem** (o quê + onde é usado), não no índice.

## 5. Global + MAPA + confirmação

- `INDEX_GLOBAL.md`: **cada** app/área com 1 linha + o grafo macro. Espelhe no `MAPA.md` (§4/§5).
- Confirme ao usuário com **números**: `N unidades / M entradas / grafo`, e que **M == N**. Se não bater, **não terminou**.
