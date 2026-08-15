# Qualidade: Tamanho, Doc-Comment, Índice, Archive e Definition of Done

> Parte da skill **schematize-web**. Reúne os pisos de **processo** — os mesmos âncoras do `schematize-go` (§6 tamanho/doc, §28 archive, §35 DoD, §39 índice), adaptados ao frontend — pra quem vem do back encontrar tudo no mesmo lugar.

## Índice
- 6. Complexidade e Tamanho (arquivos pequenos, micro-componentes, doc-comment)
- 28. Archive — INEGOCIÁVEL
- 35. Definition of Done (frontend)
- 39. Índice de Funcionalidades (global + componentes/hooks)

---

## 6. Complexidade e Tamanho

> **Canônico em `references/padroes-codigo.md`** (tamanho em camadas: teto DURO de
> **750 linhas/arquivo** — ~250 comentário + ~500 código útil — que **bloqueia**, e
> **flag em > 300 linhas de código útil** que **sempre sinaliza** sem bloquear
> (~400 em observabilidade); uma função/componente por arquivo, doc-comment
> obrigatório com motivo/comportamento/entradas/saídas/efeitos, e `MAPA.md` da
> aplicação). Esta seção traz só o **recorte de frontend** desses pisos — não
> duplica a regra, especializa.

**MUST — recorte de frontend**
- Ao quebrar um arquivo grande, faça por **coesão de front**: extrair
  sub-componentes, mover lógica pra **hooks**, separar estilos. "Componente de
  página de 800 linhas porque é uma página" não existe — página é composição de
  partes pequenas (§41).
- **Componentes/hooks pequenos e de responsabilidade única.** UI separada de
  estado separada de dados (§41, `references/dados-estado.md`).
- O doc-comment (exigido pelo canônico) deve, em front, dizer também **onde** o
  componente é usado/previsto (ex.: "herói da home", "checkout `/[locale]/checkout`")
  — é a **fonte do índice de componentes/hooks** (§39), escrita pra ser extraída:

```ts
/**
 * O quê: card de produto com imagem, título, preço e CTA.
 * Onde:  grid da listagem `/[locale]/produtos`; também no carrossel da home.
 * Props: { product }. Efeitos: nenhum (apresentação pura).
 */
```

- Exceções ao limite (não disparam quebra): testes, código gerado, arquivos de
  tipo/schema, mensagens de i18n, fixtures.

**Bloqueio em CI** (gate de front, sobre o canônico)
- Componente/hook/função de produção sem doc-comment de contexto → bloqueia.
- Complexidade ou aninhamento excessivo → revisar.

---

## 28. Archive — INEGOCIÁVEL

> **Não tem modo "pula pra ir mais rápido".** O archive é parte da entrega. Tarefa sem archive = tarefa não feita (§35). Gerar os `.md` é tão obrigatório quanto buildar.

**Princípio:** todo trabalho que produz código, decisão ou mudança de estado **gera registro em Markdown, TODA vez**. O `.md` nasce junto com o trabalho e é commitado junto.

### 28.0 Layout canônico — todo MD gerado no archive, root limpo (MUST)

**Todo `.md` gerado pela skill/agente mora em `<projeto>_archive/`, NUNCA no root do projeto.** Vale para MAPA, índices, planos, relatórios, handoffs, checkpoints — qualquer artefato gerado. O root fica **limpo**: só código, config e os poucos MDs de projeto mantidos à mão (`README.md`, `CLAUDE.md`, `LICENSE`, e ADRs se versionados em `docs/adr/`). Largar MAPA/índice/plano/relatório no root é **violação** (§37) e fere a contenção de workspace.

Subpastas canônicas (o archive **é versionado** — entra no PR):

```
<projeto>_archive/
  index/         # MAPA.md + INDEX_GLOBAL.md + INDEX_COMPONENTS.md — regenerados no lugar
  context/       # handoff/checkpoint de contexto (§34.1, references/contexto-claude-code.md)
  orchestration/ # plano + checkpoint de fan-out/paralelização
  pentest/       # ENDPOINTS.md + relatórios (schematize-pentest)
  chat/          # decisão/conversa
  task/          # implementação
```

**Regra de bolso:** antes de gravar qualquer `.md`, o caminho começa com `<projeto>_archive/`. Se você ia escrever no root, pare e mova pro archive.

**MUST — gerar SEMPRE** para:
- Decisão de arquitetura de front, de design system, de stack (Next vs Astro), de estratégia de i18n/SEO, de performance.
- Mudança de contrato consumido (API, props públicas de um componente compartilhado).
- Qualquer geração de código não trivial (inclui código assistido por IA — §34 do schematize-go).

```
<project>_archive/chat/<YYYY-MM-DD-HH-MM-SS>-<contexto>.md   # decisão/conversa
<project>_archive/task/<task-name>.md                        # implementação
```

Conteúdo mínimo (sem placeholder vazio): pergunta/objetivo, entendimento, decisão tomada, alternativas, riscos/trade-offs, próximos passos. Templates em `assets/CHAT_ARCHIVE.md` e `assets/TASK.md`.

**MUST — garantia de processo**
- PR sem o `.md` correspondente (quando a regra exige) **não passa no review**.
- Sem segredo/PII nos MDs (§43 / §16.1 do schematize-go) — `scripts/archive-secret-scan.sh` varre antes do commit.

---

## 28.1 Fluxo de ambientes e deploy pelo pipeline — INEGOCIÁVEL

> **Canônico em `references/ops.md`.** Aqui fica o recorte de processo que entra na DoD; o detalhe (precauções, artefato imutável, multi-app) está no reference.

**MUST**
- **Fluxo de promoção fixo, sem atalho:** toda mudança segue **dev local → teste local (verde) → GitHub (merge) → hml/preview → prd**. Nada pula etapa; nada vai direto pra hml/preview ou prd. Preview por PR (§54) é o "hml por mudança" — revisa visual/a11y/CWV **antes** do merge.
- **Deploy/rollback/config passam pelo pipeline de CI/CD — a interface única.** Promoção entre ambientes e reversão são **um passo** operável pelo próprio usuário, **sem depender da IA**. Detalhe do deploy/CDN/rollback em `references/operacao-deploy.md` (§54–§58).

**VETADO**
- **Editar direto no site/servidor deployado** (hml/prd): mexer no build já publicado, hotpatch de HTML/JS/CSS servido pelo CDN/host, trocar asset "na mão" no bucket/edge. O site no ar é **imutável por edição manual** — recebe só **artefato promovido do git** (commit SHA, artefato imutável; §54).
- **Deploy manual ad-hoc fora do pipeline** (`scp`/`rsync`/upload do build, "arrastar `dist/` pro painel", subir asset solto no CDN). Não tem etapa no pipeline pra aquilo? **adiciona a etapa** — não faz por fora (`references/ops.md` §2).

---

## 35. Definition of Done (frontend)

Uma task de frontend está pronta quando, cumulativamente:

- [ ] Unit + **componente** (Testing Library) passam; fluxos críticos com **e2e** (Playwright) (§48)
- [ ] **Acessibilidade:** axe sem violação `serious`/`critical`, e checagem manual de teclado/foco nos fluxos tocados (§44)
- [ ] **Core Web Vitals dentro do budget** (Lighthouse/CWV no CI) — sem regressão de LCP/INP/CLS (§45)
- [ ] **Regressão visual** verde nas telas-chave tocadas (§48)
- [ ] **Smoke prova conteúdo** (não só status) + self-check anti "verde mentiroso" (§48)
- [ ] **Nenhum anti-padrão da §37** no diff (segredo no cliente, `dangerouslySetInnerHTML` não sanitizado, token em localStorage, `any`/`@ts-ignore`, estado de loading/erro/vazio faltando, etc.)
- [ ] **Nenhum arquivo > 750 linhas** (nem > ~500 de código útil) — teto duro; arquivo/componente/função com > 300 úteis (~400 em observabilidade) **flagueado** como dívida; todo componente/hook/função com doc-comment de contexto (§6)
- [ ] **SEO/estruturados:** metadados por página, JSON-LD aplicável, **sitemap gera** corretamente (§46)
- [ ] **i18n-ready (mesmo monolíngue):** `<html lang>`/locale corretos, **nenhuma string de UI hardcoded** (catálogo por locale), formatação `Intl`, roteamento pronto pra idioma; `hreflang` recíproco quando multilíngue (§47)
- [ ] **Índice de funcionalidades atualizado no mesmo PR** — global e componentes/hooks (§39)
- [ ] Observabilidade de front: captura de erro e Web Vitals instrumentados (§49)
- [ ] **Fluxo de ambientes respeitado** (§28.1, `references/ops.md`): mudança promovida por **dev local → teste local → GitHub → hml/preview → prd**, deploy/rollback **pelo pipeline** — nada editado direto no site/servidor deployado, nenhum deploy manual ad-hoc
- [ ] **Archive de chat/task gerado e commitado** (§28) — gate rígido
- [ ] TypeScript strict, lint (incl. jsx-a11y + security) e `npm audit` limpos
- [ ] CI verde, code review aprovado

> Bloqueantes absolutos (em negrito acima): archive (§28), ausência de macaquice (§37), a11y sem violação séria, CWV no budget, e smoke que prova conteúdo. Faltando qualquer um, **não está pronto** — independente do resto estar verde. Build verde não basta: tem que ser verde que **prova** conteúdo, acessibilidade e velocidade.

---

## 39. Índice de Funcionalidades (fonte da verdade viva)

O código diz **como** está agora; o índice diz **o que existe, onde mora e como se faz** — **fonte da verdade**, consultada antes de criar algo (anti-duplicação) e atualizada a cada mudança.

**MUST — dois níveis**
- **Índice global** (`INDEX_GLOBAL.md`) — mapa macro: páginas/rotas, áreas (marketing, app, docs), layouts, design system, integração com APIs (quais consome), estratégia de i18n/SEO. O "mapa do território". Mantido à mão, revisado a cada mudança estrutural.
- **Índice de componentes/hooks** (`INDEX_COMPONENTS.md`) — catálogo fino: cada componente/hook → **o quê**, **onde é usado**, props/efeitos, arquivo:linha. **Gerado** dos doc-comments (§6) por `scripts/build-index.mjs`.

**MUST — atualização e gate**
- Todo PR que adiciona/remove/move funcionalidade atualiza o índice **no mesmo PR**. Índice desatualizado **trava o merge** (item da DoD, §35).
- Consulte o índice **antes** de criar um componente — pra não reimplementar o botão/card/modal que já existe (anti-duplicação; liga com DRY semântico).

**SHOULD — geração assistida**
- O índice de componentes é **gerado por script** que varre os doc-comments padronizados e monta `componente → o quê → onde → arquivo:linha`. CI compara o gerado com o commitado; divergência aponta índice ou comentário desatualizado.

**MUST — completude (uma entrada por componente/hook/função, sem "relevante")**
- O índice é **exaustivo**: **uma entrada por** componente, hook, função utilitária, rota/página e provider — **público e privado**. Não existe "componente irrelevante": se está no código, está no índice.
- **Invariante verificável (conte, não confie):** por app/pacote, `nº de entradas == nº de componentes/hooks/funções declarados`. O `/web-index` e o CI **contam as declarações** (componente = função/const que retorna JSX; hook = `use*`; funções; rotas) e **reprovam** se o índice tiver **menos** entradas — listando as ausentes **pelo nome**. Índice de 90 linhas para 100+ unidades é **falha dura**. O índice **enumera**, não resume.
- **Cobertura total:** o índice global lista **cada** app/pacote/área; cada um tem seu catálogo de componentes/hooks **completo**.

**MUST — o índice é um GRAFO, não uma lista**
- Carrega um **grafo textual**: nós = componentes/hooks/rotas; arestas = **quem renderiza/usa quem** (out) e **quem o usa** (in). No macro, o grafo de **rotas → páginas → componentes** e o de **consumo de APIs/BFF**. Formato: bloco **Mermaid** (`flowchart`) **+** adjacência em lista (pra diff/grep). Mostra o **raio de impacto** de mudar um componente.

> O índice responde "esse componente já existe? onde? como faço X?" sem caçar no código. Se a resposta exige caçar, o índice falhou — e isso é bug.
