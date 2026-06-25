---
description: (Re)gera o índice de componentes/hooks (§39) a partir dos doc-comments
argument-hint: "[dir de origem, ex: src]"
---

Atualize o **índice de funcionalidades** (§39), que é fonte da verdade do projeto.

1. Rode `node scripts/build-index.mjs ${ARGUMENTS:-src}` e grave a saída em
   `<projeto>_archive/index/INDEX_COMPONENTS.md`.
2. Se o script sair com código 1, há componente/hook/função sem doc-comment de
   contexto (§6): liste-os e corrija na origem (o quê + onde é usado), não no índice.
3. Revise o `INDEX_GLOBAL.md` (mantido à mão): páginas/rotas/áreas/o que cada uma faz
   continuam corretos? Atualize se a mudança mexeu na estrutura de navegação.
4. Confirme que o índice reflete o estado atual — índice desatualizado é bug (§39).
