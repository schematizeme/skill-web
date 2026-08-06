---
description: Roda o gate da Definition of Done e anti-padrões de frontend (§35, §37) no diff atual
argument-hint: "[ref git, ex: origin/main]"
---

Faça o **review de padrões** do diff atual (contra $ARGUMENTS ou `origin/main`),
combinando o checker determinístico com seu julgamento.

1. Rode `bash scripts/check-diff.sh ${ARGUMENTS:-origin/main}` e leia o resultado.
2. Some a isso a análise que o script NÃO faz bem sozinho:
   - **§43 (segurança):** segredo no cliente / `NEXT_PUBLIC_`; token em `localStorage`;
     auth/authz decidida só no client; `dangerouslySetInnerHTML` sem sanitizar de verdade;
     ausência de CSP/headers; open-redirect sem allowlist; CSRF.
   - **§44 (a11y):** falta de semântica/landmark, foco não gerenciado em modal/rota,
     contraste insuficiente, `aria-*` redundante/errado, formulário sem label/erro associado.
   - **§45 (performance):** imagem sem dimensão (CLS), sem `next/image`/otimização, fonte
     bloqueante, bundle inchado, falta de code splitting, regressão de budget CWV.
   - **§41/§42:** componente extenso (>300 úteis dispara flag; >750/≈500 úteis bloqueia), lógica no JSX em vez de hook, estado mal
     colocado/prop drilling, data fetching sem loading/erro/vazio, `fetch` sem cleanup.
   - **§6/§39:** arquivo acima do teto (750/≈500 úteis) sem quebra, ou >300 úteis flagueado como dívida; componente/hook sem doc-comment (o quê + onde);
     índice atualizado no mesmo PR?
   - **§40:** backend disfarçado no front? (delega ao schematize-go).
3. Produza um relatório com `BLOQUEIA` (viola piso/DoD) e `ATENÇÃO` (melhorar),
   citando arquivo:linha. Qualquer `BLOQUEIA` → a task **não está pronta** (§35).

Seja específico e acionável — aponte o conserto, não só o problema.
