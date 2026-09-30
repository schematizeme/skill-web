# Arquitetura de Frontend: Fronteira Client/Server, Componentes, Estado e Data Fetching

> Parte da skill **schematize-web**. Governa o **frontend**: fronteira client/server, composição de componentes, estado e busca de dados. Servidor de verdade, API, banco e infra de back **não** são deste skill — delegam à skill da linguagem de backend do projeto. Referências cruzadas (§N) apontam para seções do corpo do schematize-web.

## Índice
- 40. Stack e Fronteira Client/Server
- 41. Componentes e Estado
- 42. Data Fetching (busca de dados)

---

## 40. Stack e Fronteira Client/Server

### 40.1 Stack permitida

**MUST**
- **Site/app novo é Next.js ou Astro.** Nenhum outro framework sem ADR.
  - **Next.js** — app dinâmico, SSR, áreas autenticadas, App Router + React Server Components. É o default quando há interatividade rica e renderização no servidor.
  - **Astro** — site content-driven, marketing, docs, blog, conteúdo majoritariamente estático com ilhas de interatividade. É o default quando o alvo é HTML mínimo e velocidade máxima.
- **TypeScript `strict` obrigatório** (ver `assets/lint/tsconfig.strict.json`). `any`, `@ts-ignore`, `@ts-nocheck` pra calar o compilador são VETADOS (§37).
- **Node é 100% permitido — e só no frontend.** O server-side do próprio front (route handler, server action, middleware, BFF, adapter de Astro) é frontend e segue o §43 (segredo só server-side). Isso **não** reabre Node como backend de serviço — back de verdade é Go/Rust (`schematize-engineering`).
- Versões LTS correntes (Next/Astro/React/TS/Node) ficam em `references/stack-versoes.md` (Anexo A) — consulte lá, não decore.
- **Nome do repositório:** mesma convenção da casa — `<projeto>_<contexto>[_<lang>]` em snake_case minúsculo, um repo por app/contexto. No frontend o `<contexto>` costuma ser `front`, `web`, `admin`, `site`; `_<lang>` opcional (`_ts`). Ex.: `loja_front`, `loja_admin_ts`. Detalhe em a skill da linguagem de backend do projeto (rol: `schematize-engineering`, `schematize-rust`, `schematize-elixir`, `schematize-csharp`, `schematize-zig`, `schematize-ruby`) (§2).
- **Contenção no workspace (nunca sair da pasta do projeto):** o **diretório de projeto atual é o workspace**; todo app/site nasce e mora **dentro dele**. Vai criar um app novo? Crie uma **pasta pra ele dentro da pasta atual** (`./<projeto>_<contexto>/`) — **nunca** largue arquivos soltos no root pra depois **subir de diretório** (`cd ..`, `../`) e criar os outros repos fora. Repos são **irmãos dentro do mesmo workspace**, não espalhados pela máquina. **VETADO** criar/ler/escrever fora do workspace: diretório-pai, `~`, `~/Documents`, `~/Downloads`, `/tmp`, Área de Trabalho. O agente **não sai da pasta do projeto** — nem pra vasculhar, nem pra criar — a menos que o usuário peça explicitamente.

**SHOULD**
- Em empate técnico entre Next e Astro para um site de conteúdo, **Astro vence** (menos JS no cliente é melhor pro alvo de velocidade).
- Estilo: solução com baixo custo de runtime (CSS Modules, Tailwind, vanilla-extract ou CSS-in-JS *zero-runtime*). CSS-in-JS com runtime pesado precisa de justificativa de budget (§45).

### 40.2 Fronteira client/server — explícita e a favor do servidor

A regra central do frontend moderno: **o máximo possível roda no servidor; o cliente recebe o mínimo de JS necessário.** A fronteira é uma decisão de arquitetura, não um acidente.

**MUST**
- **Marcar a fronteira de propósito.** Em Next App Router, componente é **Server Component por padrão**; `"use client"` é uma escolha consciente, no menor componente possível (folha), não no topo da árvore. Em Astro, o default é zero-JS; `client:*` em ilha é a exceção justificada.
- **Tudo que toca segredo, credencial, banco ou terceiro com chave roda no servidor** (route handler, server action, server component que **não serializa segredo pra props**, BFF). O browser nunca segura segredo (§43).
- **Server Action / route handler valida a entrada de novo no servidor.** Validação no cliente é UX; a que importa é a do servidor. Autorização idem é server-side (§43).
- **Sem cascata de waterfall desnecessária.** Busca de dados de uma página é paralelizada/colocalizada no servidor; não serializar requisições que poderiam ser concorrentes.

**VETADO**
- Subir pro cliente (`"use client"`) um componente só porque "é mais fácil" quando ele não precisa de interatividade — infla o bundle (§45) e arrasta dependências.
- Passar segredo de Server Component pra Client Component via props (vira bundle). Props que cruzam a fronteira são dados públicos, serializáveis.
- BFF que repassa o body inteiro do cliente pro upstream sem allowlist de campos (mass assignment — §43).

> A fronteira client/server é onde mora metade dos bugs de segurança e de performance de front. Desenhe-a explicitamente: servidor por padrão, cliente por necessidade.

---

### 40.3 As APIs do App Router que a casa usa (e o que muda com cada uma)

> Esta skill governava App Router/RSC **sem nomear uma única API dele** — `cookies()`, `headers()`,
> `useActionState()`, `after()` e `"use cache"` tinham **zero ocorrências**. O efeito prático é
> concreto e caro: sem os nomes, o modelo gera código do **Pages Router** (`getServerSideProps`,
> `useFormState`, `router.query`) num projeto App Router, e o time descobre no build. Achado do
> inventário da vistoria de 2026-08-21.

| API | O que é | O que muda no desenho |
|---|---|---|
| **`cookies()`** (`next/headers`) | leitura/escrita de cookie **no servidor** | é **assíncrona** (`await cookies()`) e **torna a rota dinâmica**. É por onde o token `HttpOnly` é lido — o cliente **nunca** o vê (§43.2). Escrever só em Server Action ou Route Handler. |
| **`headers()`** (`next/headers`) | headers da request no servidor | também **assíncrona** e dinamizante. É de onde saem `tenant`, locale e `trace_id` — nunca de prop vinda do cliente (§43.6). |
| **`useActionState()`** (React 19) | estado de retorno de Server Action no cliente | **substituiu `useFormState`**. É o caminho da casa para form: o *submit* vai ao servidor mesmo sem JS (progressive enhancement), e o erro de validação volta **do servidor**, que é onde a validação vale. |
| **`after()`** (`next/server`) | trabalho **depois** da resposta, no mesmo request | é onde vai log/telemetria/efeito não-crítico **sem** segurar o TTFB. **Não** é fila: trabalho que precisa de retry/durabilidade vai para outbox/worker (§42), não para o `after()`. |
| **`"use cache"`** | marca função/rota como cacheável, com `cacheLife`/`cacheTag` | cache **explícito e invalidável por tag** no lugar de heurística. Regra da casa: **nada de dado por usuário/tenant dentro de escopo cacheado** — cache que cruza tenant é vazamento, não performance. |

**MUST**

- **`cookies()`/`headers()` são `await`** e **dinamizam a rota** — chamá-las "só para ler um valor"
  em layout compartilhado derruba a estática do site inteiro. Leia o mais **fundo** possível na
  árvore, não no topo.
- **Server Action é endpoint público.** Ela recebe input do cliente e **precisa de validação e
  authz próprias** — o fato de "só o meu form chamar" não é controle de acesso (§43.6).
- **`useActionState` no lugar de `useFormState`** (renomeada no React 19); e `useFormStatus` só
  dentro do `<form>`.
- **`after()` não substitui outbox.** Se o efeito precisa acontecer *mesmo que o processo caia*, é
  outbox (`schematize-engineering` → `references/dados-eventos.md`).
- **APIs do Pages Router são VETADAS em projeto App Router:** `getServerSideProps`,
  `getStaticProps`, `getInitialProps`, `router.query` do `next/router`. Aparecendo no diff, é sinal
  de código gerado com o modelo mental errado — revise o arquivo inteiro, não só a linha.


## 41. Componentes e Estado

### 41.1 Componentes pequenos e de responsabilidade única

**MUST**
- **Componente faz uma coisa.** Separe **UI** (apresentação), **estado/lógica** (hooks) e **dados** (fetch/loader). Um componente que busca, decide e desenha as três coisas vira intestável e gigante.
- **Tamanho de arquivo em camadas** (§6): teto DURO de **750 linhas** (~250 comentário + ~500 código útil) que **bloqueia** — acima, quebre em **micro-componentes** e **hooks** com nome que explica a intenção. **Flag (não bloqueia, sempre sinaliza) em > 300 linhas de código útil**: indício de componente extenso / falta de abstração, vira dívida pra rever. "Componente de 800 linhas porque é uma página" não existe — página é composição de partes pequenas.
- **Todo componente/hook/função tem doc-comment de contexto** (§6): o **quê** (o que faz) e **onde** (em que página/fluxo é usado), além de props/efeitos relevantes. Esse comentário alimenta o índice de componentes (§39).

**SHOULD**
- Componentes de apresentação são "burros" (recebem props, não buscam dados). A busca fica em Server Components / loaders / hooks de dados, na borda.
- Listas sempre com **`key` estável** (id do dado, nunca o índice quando a lista reordena/filtra) — §37.

### 41.2 Disciplina de estado

O estado errado no lugar errado é a causa raiz de re-render em cascata, prop drilling e bugs de sincronização.

**MUST**
- **Estado o mais perto possível de quem usa.** Não suba estado pro topo "por precaução". Estado local fica local.
- **Sem prop drilling profundo** (passar prop por 4+ níveis que não a usam). Use composição (`children`), ou contexto **estreito e específico**, ou um store dedicado.
- **Sem contexto inflado** — um `AppContext` que carrega tudo re-renderiza meio app a cada mudança. Contextos pequenos, por domínio, com valor memoizado.
- **Servidor é a fonte da verdade dos dados do servidor.** Estado de servidor (dados remotos) é gerido por uma camada de data fetching com cache/revalidação (§42), **não** copiado pra dentro de `useState` e mantido à mão.

**SHOULD**
- Distinga **estado de UI** (aberto/fechado, aba ativa) de **estado de servidor** (dados remotos) de **estado de URL** (filtros, página, busca — que devem viver na query string pra serem compartilháveis e voltarem no histórico).
- Derive em vez de duplicar: o que dá pra calcular de outro estado não vira novo estado (fonte de dessincronização).

**VETADO**
- `useEffect` pra sincronizar estado que é derivável (calcula no render).
- Guardar no estado do cliente dado que deveria vir do servidor com cache — convida bug de "tela mostra X, banco tem Y".

### 41.3 Design de API de componente

Um componente reutilizável é uma **API**: props mal desenhadas viram dívida que
todo consumidor herda.

**MUST**
- **Composição sobre configuração.** Prefira `children`/slots a uma explosão de
  props booleanas (`showHeader`, `showFooter`, `variantBigRed`). Componente que
  cresce em flags vira ingerível — quebre em partes compostas.
- **Controlado vs não-controlado, escolha clara.** Input/widget é *controlado*
  (`value` + `onChange`) **ou** *não-controlado* (`defaultValue`) — documentado, não
  os dois pela metade (a troca a meio caminho é o bug clássico de form em React).
- **Props nomeadas pela intenção**, não pela implementação; handlers `onX` (evento),
  estado por adjetivo (`isOpen`, `disabled`). Tipos explícitos (sem `any`).
- **Acessibilidade na API:** o componente repassa `aria-*`/`id`/`ref` necessários
  e não impede o consumidor de rotular (liga com §44). Não engole o `ref`.

**SHOULD**
- **Default seguro** pra toda prop opcional; o uso mínimo (`<Componente />`) já é
  válido e acessível.
- Variantes por um `variant`/`size` enumerado (mapeado a tokens — `design-tokens.md`),
  não estilos soltos por prop.
- Não vazar detalhe interno na API pública (estrutura de DOM, classe CSS) — o
  consumidor depende do contrato, não da implementação.

**VETADO**
- Componente "deus" parametrizado por 15 props que faz cinco coisas — é cinco
  componentes disfarçados.
- Prop que muda o **comportamento semântico** drasticamente (um `<Button>` que vira
  link, modal e tab conforme a flag).

---

## 42. Data Fetching (busca de dados)

**MUST**
- **Buscar no servidor por padrão.** Em Next, dados de uma página vêm em Server Components / route handlers com a estratégia de cache/revalidação explícita. Em Astro, no frontmatter/loader em build ou via Live Collections quando precisa de dado fresco.
- **Cache e revalidação explícitos.** Toda busca declara sua política: estático (build), revalidação por tempo (ISR/`revalidate`), ou dinâmico (sem cache). Nada de "deixa o default e reza".
- **Os três estados, SEMPRE: `loading`, `error`, `empty`.** Toda busca de dados no cliente trata carregamento, falha (com mensagem e caminho de recuperação, não tela branca) e **vazio** (lista sem itens é um estado de UI projetado, não um bug visual). Ignorar qualquer um dos três é VETADO (§37).
- **`fetch` no cliente com cancelamento.** Efeito que busca dados tem **cleanup** que aborta a requisição (`AbortController`) e ignora resposta de request obsoleta — senão há vazamento e *race* de "resposta velha sobrescreve a nova". `fetch` em `useEffect` sem cleanup é VETADO (§37).
- **Erro de fetch é tratado, nunca engolido.** Sem `.catch(() => {})`. Logue/reporte com contexto (§49) e degrade a UI de forma consciente.

**SHOULD**
- Prefira a primitiva de dados do framework (Server Components, `loader`, server actions) à busca manual no cliente. Quando precisar de cliente, use uma lib de data fetching com cache, dedupe e revalidação (ex.: React Query/SWR) em vez de `useEffect` + `useState` na unha.
- **Otimismo com rollback.** Update otimista precisa reverter em caso de falha — UI que mente em caso de erro é pior que UI lenta.
- Paginação por **cursor** quando a lista cresce; estados de "carregando mais" e "fim da lista" explícitos.

**MAY**
- Streaming/Suspense para enviar o shell rápido e preencher partes pesadas depois — ajuda LCP/INP (§45) quando bem usado.

> Data fetching sem os três estados (loading/erro/vazio) é uma demo, não um produto. E `fetch` em efeito sem abort é uma corrida esperando pra dar tela errada.

---

## Dependências entre camadas (resumo)

```
página/rota (server)  → busca dados, decide layout, monta a árvore
  └─ componentes server → apresentação sem segredo, podem buscar
       └─ ilhas/client  → interatividade mínima, recebem dados já resolvidos
hooks (estado/lógica)   → isolam estado; não desenham
camada de dados         → cache/revalidação; fonte da verdade do remoto
```

Segredo, autorização e chamada a terceiro com chave **nunca** descem pra camada client — sobem pro servidor (§43).
