---
description: Context Compact — gera handoff (context.md + checklist.md) no <projeto>_archive e compacta
argument-hint: "[foco opcional, ex: bug de hidratação]"
---

Você vai fazer o **handoff de contexto** desta sessão ANTES de compactar (§34.1, §28).
Execute nesta ordem, sem pular nenhum passo. Se houver argumento ($ARGUMENTS), use-o
como foco do resumo e da compactação.

1. **Pasta e timestamp.** Use `${PROJECT_ARCHIVE:-<projeto>_archive/context}` como
   destino e o timestamp atual no formato `YYYY-MM-DD-HH-MM-SS` (chame de `<ts>`).
   Crie a pasta se não existir.

2. **Escreva `<ts>-context.md`** — o CONTEXTO GERAL até aqui:
   - Objetivo da sessão / o que está sendo construído (página, fluxo, componente).
   - Decisões tomadas e o porquê (e ADRs criados, se houver).
   - Componentes/rotas/arquitetura de UI tocados e **arquivos alterados** (com caminho).
   - Estado atual: o que renderiza/funciona, o que está quebrado/pendente (a11y, CWV, testes).
   - Threads em aberto e dúvidas não resolvidas.
   - Como retomar: comandos (`dev`, `build`, `test`, `e2e`), env (`.env.local`), portas.

3. **Escreva `<ts>-checklist.md`** — DETALHADO o bastante pra uma sessão nova NÃO
   repetir trabalho:
   - `## FEITO` — cada item concluído com detalhe (o quê, onde, como ficou).
   - `## EM ABERTO / A FAZER` — cada pendência com **próximo passo concreto**,
     arquivo/local e critério de pronto (inclui gates de a11y/CWV ainda não passados).
   - `## NÃO REFAZER` — caminhos/becos já descartados e o porquê.

4. **Confirme** ao usuário os dois caminhos exatos gravados.

5. **Compacte.** Rode `/compact` mantendo o foco na tarefa corrente (use $ARGUMENTS
   se foi passado). Se a sua versão do Claude Code não permitir disparar `/compact`
   de dentro de um comando, avise o usuário pra rodar `/compact` em seguida — o
   handoff já está salvo.

**Regras:** nunca pule a escrita dos dois arquivos. Armazene SEMPRE em
`<projeto>_archive` (§28). Não inclua segredo nem PII nos MDs (§43/§49).
