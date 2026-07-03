# Qualidade: Tamanho, Doc-Comment, Índice, Archive e Definition of Done

> Parte da skill **schematize-web**. Reúne os pisos de **processo** — os mesmos âncoras do `schematize-go` (§6 tamanho/doc, §28 archive, §35 DoD, §39 índice), adaptados ao frontend — pra quem vem do back encontrar tudo no mesmo lugar.

## Índice
- 6. Complexidade e Tamanho (arquivos pequenos, micro-componentes, doc-comment)
- 28. Archive — INEGOCIÁVEL
- 35. Definition of Done (frontend)
- 39. Índice de Funcionalidades (global + componentes/hooks)

---

## 6. Complexidade e Tamanho

> **Canônico em `references/padroes-codigo.md`** (≤ 300 linhas/arquivo, uma
> função/unidade por arquivo, função > 300 linhas quebrada, doc-comment
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

## 35. Definition of Done (frontend)

Uma task de frontend está pronta quando, cumulativamente:

- [ ] Unit + **componente** (Testing Library) passam; fluxos críticos com **e2e** (Playwright) (§48)
- [ ] **Acessibilidade:** axe sem violação `serious`/`critical`, e checagem manual de teclado/foco nos fluxos tocados (§44)
- [ ] **Core Web Vitals dentro do budget** (Lighthouse/CWV no CI) — sem regressão de LCP/INP/CLS (§45)
- [ ] **Regressão visual** verde nas telas-chave tocadas (§48)
- [ ] **Smoke prova conteúdo** (não só status) + self-check anti "verde mentiroso" (§48)
- [ ] **Nenhum anti-padrão da §37** no diff (segredo no cliente, `dangerouslySetInnerHTML` não sanitizado, token em localStorage, `any`/`@ts-ignore`, estado de loading/erro/vazio faltando, etc.)
- [ ] **Arquivos ≤ 300 linhas** e todo componente/hook/função com doc-comment de contexto (§6)
- [ ] **SEO/estruturados:** metadados por página, JSON-LD aplicável, **sitemap gera** corretamente (§46)
- [ ] **i18n-ready (mesmo monolíngue):** `<html lang>`/locale corretos, **nenhuma string de UI hardcoded** (catálogo por locale), formatação `Intl`, roteamento pronto pra idioma; `hreflang` recíproco quando multilíngue (§47)
- [ ] **Índice de funcionalidades atualizado no mesmo PR** — global e componentes/hooks (§39)
- [ ] Observabilidade de front: captura de erro e Web Vitals instrumentados (§49)
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

> O índice responde "esse componente já existe? onde? como faço X?" sem caçar no código. Se a resposta exige caçar, o índice falhou — e isso é bug.
