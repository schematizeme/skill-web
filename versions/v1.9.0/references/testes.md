# Testes de Frontend — "Verde de Verdade"

> Parte da skill **schematize-web**. Testa-se **comportamento, conteúdo, acessibilidade e velocidade** — não "renderizou". O fluxo de Q.A. plan-first (§48.7) espelha o do `schematize-go` (§22.9), adaptado às categorias de frontend.

## Índice
- 48. Testes
  - 48.1 Pirâmide de frontend
  - 48.2 Unit e componente (Testing Library)
  - 48.3 End-to-end (Playwright)
  - 48.4 Acessibilidade (axe)
  - 48.5 Regressão visual
  - 48.6 Smoke anti "verde mentiroso"
  - 48.7 Q.A. plan-first (aprovação obrigatória)

---

## 48. Testes

### 48.1 Pirâmide de frontend

**MUST** — cobrir os eixos, não só um:
- **Unit** — funções puras, hooks, utilitários, formatação i18n.
- **Componente** — comportamento e acessibilidade de cada componente (Testing Library).
- **e2e** — fluxos críticos ponta-a-ponta no browser real (Playwright).
- **a11y** — axe por página/estado.
- **Regressão visual** — snapshot de pixel das telas-chave.

Caminhos críticos (auth na UI, checkout, formulários que enviam dados, troca de idioma, navegação) têm testes explícitos cobrindo sucesso, **erro** e **vazio**.

### 48.2 Unit e componente (Testing Library)

**MUST — testar como o usuário usa, não como o código é feito**
- **Consultar por papel/acessibilidade** (`getByRole`, `getByLabelText`), não por classe CSS ou id interno. Se o teste não acha o botão por papel/nome, o usuário de leitor de tela também não acha — o teste vira teste de a11y de graça.
- **Assere conteúdo e estado, não existência.** `expect(container).toBeTruthy()` / "renderizou sem quebrar" é teatro. Verifique o **texto**, o **valor**, o **estado** (desabilitado, aberto, selecionado) e a **mudança após interação** (`userEvent.click` → o que mudou).
- **Caminho de erro e vazio obrigatórios.** Pra cada componente que busca/recebe dados: estado de loading, de erro (mensagem + recuperação) e de lista vazia — espelhando o §42.
- **Casos hostis** em inputs: string vazia, gigante, unicode/emoji/RTL, caractere especial — o componente não pode quebrar nem refletir sem escape.

**VETADO**
- Mock que devolve exatamente o esperado e "passa" sem exercitar lógica (verde falso).
- Snapshot gigante de DOM como único teste (quebra a cada espaço, não prova comportamento).
- `test.only` esquecido, `.skip` pra "passar o CI", `expect(true).toBe(true)`.

### 48.3 End-to-end (Playwright)

**MUST**
- Fluxos críticos no **browser real**: login na UI, navegação principal, envio de formulário (com validação e erro do servidor), troca de idioma (URL muda, conteúdo traduz), e qualquer jornada que dá dinheiro/dado.
- Assere **conteúdo e resultado**, não só que a página abriu. Testar em **mobile viewport** também (é o caso de referência — §45).
- Sem `waitForTimeout` mágico; espere por estado/elemento (auto-waiting do Playwright).

### 48.4 Acessibilidade (axe)

**MUST**
- **axe roda por página e por estado dinâmico** (modal aberto, menu expandido, formulário com erro) no CI.
- Violação **`serious`/`critical` bloqueia o merge** — igual teste quebrado (§35). `moderate`/`minor` viram issue rastreável.
- axe cobre só parte; o resto é manual (§44): teclado, leitor de tela e contraste nos fluxos tocados.

### 48.5 Regressão visual

**MUST**
- Snapshot de pixel das **telas-chave** (home, herói, listagem, página de produto/artigo, checkout) em desktop e mobile. Diferença visual inesperada **falha** e exige revisão humana (aprovar ou consertar).
- Baseline versionado; mudança intencional re-baseia conscientemente (no PR), nunca "aceita tudo" cego.

**SHOULD**
- Cobrir estados (hover/focus visível, dark mode se houver, erro, vazio) e variação por locale quando o layout muda com o idioma.

### 48.6 Smoke anti "verde mentiroso"

Um smoke que só confere `200` é teatro: a rota responde, o conteúdo está quebrado, e o deploy passa. Para impedir (espelha §22.3 do schematize-go):

**MUST**
- **Assertar conteúdo do HTML servido**, não só status: a página tem o texto/elemento esperado (h1, herói, CTA), `<title>` e meta corretos, JSON-LD presente onde deve.
- **Assertion negativa:** sem placeholder não renderizado (`{{`, `${`, `%s`), sem `undefined`/`null`/`NaN` no texto, **sem erro de hidratação** no console, sem stack trace na resposta.
- **Self-check (meta-teste):** um caso que **força falha conhecida** (rota fake deve dar 404; uma asserção que deve falhar em modo `--self-check`) pra provar que o runner **sabe reportar FAIL**. Se o self-check "passa" quando deveria falhar, o smoke está cego → CI quebra.
- **CWV/budget no smoke pós-deploy:** página-chave aferida contra o budget (§45); lenta demais = FALHA. Sem `|| true`, sem swallow.

Use `scripts/smoke-selfcheck.sh` (bundlado) e os helpers de `scripts/lib.sh` (`assert_body_contains`, `http_call`, `test_fail`...).

> Smoke que nunca falha não é smoke saudável — é smoke quebrado. Se você não viu ele falhar de propósito, não sabe se funciona.

### 48.7 Q.A. plan-first (aprovação obrigatória)

A malha de Q.A. inclui passos potencialmente custosos/destrutivos (e2e contra ambiente, regeneração de baselines visuais, carga). Por isso **nenhuma submissão roda às cegas** — espelha §22.9 do schematize-go.

**MUST — antes de executar**
1. **Planejar tudo primeiro** (sem executar): quais modos (unit/componente/e2e/a11y/visual/smoke/CWV), ambiente alvo, páginas/fluxos afetados, ordem, dependências, passos que reescrevem baseline ou batem em serviço externo, e riscos.
2. **Gerar MD de passo a passo** em `<project>_archive/qa/<ts>-<contexto>.md` (archive obrigatório — §28): objetivo, comando exato, ambiente, resultado esperado, critério pass/fail, flag de "reescreve baseline/destrutivo".
3. **Pedir aprovação explícita.** Sem "ok", nada roda. Aprovação parcial vira o escopo efetivo.

**MUST — após aprovado**
4. **Oferecer modalidade:** *faseado e assistido* (pausa entre fases, mostra parcial — default pra qualquer passo que reescreva baseline visual) **ou** *de uma vez (autônomo)*.
5. No autônomo: **subagents** paralelizam categorias independentes (a11y, visual, e2e por suíte) respeitando dependências; **watchdog** retoma de checkpoint até concluir, com condição de parada explícita e **sem retry infinito**. Re-baseline visual e e2e contra produção exigem confirmação extra no momento.

**VETADO**
- Pular o plano/aprovação "pra ir mais rápido" — é macaquice da §37. Q.A. sem plano aprovado **não roda**.

---

## Integração com CI (resumo)

- **PR (rápido):** unit + componente + a11y (axe) + lint + typecheck + smoke self-check + Lighthouse CI (budget). Ver `assets/ci/github-actions-ci.yml`.
- **Pré-deploy:** e2e (Playwright) + regressão visual.
- **Pós-deploy:** smoke que prova conteúdo + CWV de campo confirmando o budget.
- Bloqueio de merge: qualquer falha de a11y séria, CWV fora do budget, visual não aprovado, ou teste vermelho **trava**.
