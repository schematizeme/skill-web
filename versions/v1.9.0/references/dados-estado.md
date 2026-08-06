# Dados, Estado e Formulários

> Parte da skill **schematize-web**. Cobre o miolo do front moderno: como buscar
> dados (e cachear), como mutar com segurança, onde mora o estado, e formulários
> com validação que a fonte da verdade é o servidor. Liga com `arquitetura.md`
> (fronteira client/server), `seguranca.md` (auth/segredo) e `performance.md`.

## Índice
- 50. Data fetching e cache
- 51. Mutations (server actions / route handlers)
- 52. Estado: servidor, cliente e URL
- 53. Formulários e validação

---

## 50. Data fetching e cache

**MUST**
- **Buscar no servidor por padrão** (RSC / loader / SSG): o dado chega renderizado,
  sem waterfall de `fetch` no cliente nem segredo no bundle (§40, §43).
- **Sem request waterfall:** dados independentes são buscados **em paralelo**
  (`Promise.all`, ou disparar as queries antes de `await`). Nunca encadear `await`
  só por hábito quando não há dependência.
- **Estado de cada busca tratado:** loading, **erro** (com recuperação) e **vazio**
  — sempre (espelha §42). `fetch` em `useEffect` sem `AbortController`/cleanup é bug.
- **Cache é decisão explícita, por requisição.** Defina e documente: o que é
  estático (cacheável), o que revalida por tempo (ISR/`revalidate`), e o que é
  sempre dinâmico (`no-store`, dado por usuário/sessão). Nunca cachear resposta
  que depende de auth/sessão num cache compartilhado.
- **Revalidação direcionada:** ao mutar, invalide por **tag/caminho**
  (`revalidateTag`/`revalidatePath` no Next; rebuild/purge no Astro/host) — não
  estoure o cache inteiro nem confie em TTL pra refletir uma escrita.

**SHOULD**
- `stale-while-revalidate` para dado que tolera leve defasagem (lista pública).
- No cliente, quando precisar (dado em tempo real, paginação infinita), usar um
  cache de servidor-estado (TanStack Query/SWR) com chave estável — **não**
  `useEffect` + `useState` ad-hoc espalhado.

**VETADO**
- Buscar com **chave secreta** direto do cliente (§43.1) — passa por BFF/route handler.
- Cachear dado por-usuário em cache público (vazamento cross-usuário).
- Over-fetch: trazer o objeto inteiro pra usar um campo. Selecione no servidor.

---

## 51. Mutations (server actions / route handlers)

**MUST**
- **Toda escrita acontece no servidor** (server action / route handler), nunca
  chamando a API privada direto do browser. A action é uma **fronteira de
  confiança**: trata todo argumento como hostil.
- **Re-valida no servidor:** schema (tipo/formato) **e** autorização
  (`user_id`/`tenant_id`/role do token verificado — §43.6), a cada chamada.
  Validação no cliente é UX; a do servidor é o controle.
- **CSRF/origem:** mutação por cookie de sessão verifica origem/refer e/ou token
  anti-CSRF (§43.5). Server action de escrita não confia só no `SameSite`.
- **Idempotência** onde faz sentido (retry de pagamento/criação) via chave de
  idempotência; a action devolve resultado tipado (sucesso/erro de domínio), não
  exceção crua pro cliente.

**SHOULD**
- **UI otimista** só com rollback em erro: aplica o efeito na hora, reverte e
  comunica se a action falhar. Sem rollback, é mentira de UI.
- Revalidar/atualizar o cache afetado logo após a mutação (§50).

**VETADO**
- Confiar em valor vindo do cliente para decisão de acesso ou preço (recalcule no
  servidor). Esconder ação só no render (§43.6) — o dado/efeito já foi.

---

## 52. Estado: servidor, cliente e URL

Classifique o estado **antes** de escolher a ferramenta. A maioria dos bugs de
front nasce de tratar estado de servidor como estado de cliente.

**MUST**
- **Estado de servidor** (dado que vem da API/DB): vive no cache de data-fetching
  (§50), **não** é copiado pra um store global e mantido "na mão". Fonte da
  verdade é o servidor; o cliente só espelha.
- **Estado de URL** (filtro, aba, página, busca, ordenação): mora na **URL**
  (query/segmento). É compartilhável, sobrevive a refresh, é indexável e dá
  voltar/avançar de graça. Não duplicar em `useState`.
- **Estado de UI local** (modal aberto, input controlado, hover): `useState`/
  `useReducer` no componente. Não promova a global o que é local.

**SHOULD**
- Estado global de cliente (tema, carrinho offline, sessão de UI) só quando
  realmente compartilhado entre rotas distantes — e com store enxuto (Zustand/
  contexto pequeno), não um balaio que vira fonte de re-render geral.

**VETADO**
- Store global espelhando o servidor e dessincronizando (duas fontes da verdade).
- Guardar em estado o que é derivável (calcule no render); estado derivado
  desatualizado é bug clássico.

---

## 53. Formulários e validação

**MUST**
- **Um schema, duas pontas.** O mesmo schema (ex.: Zod/Valibot) valida no cliente
  (UX imediata) **e** no servidor (controle real). A do servidor é **a fonte da
  verdade** — o cliente pode ser burlado.
- **Progressive enhancement:** o formulário funciona com o mínimo de JS quando
  possível (server action / `method=post`), e o JS melhora a experiência — não é
  pré-requisito pra enviar.
- **Erros acessíveis e textuais** (§44.6): ligados ao campo (`aria-describedby`),
  anunciados, foco no primeiro erro. Erro do servidor volta mapeado pro campo.
- **Estados do envio:** desabilitar/sinalizar enviando, tratar falha do servidor
  (mensagem + permitir retry), confirmar sucesso. Nada de duplo-submit.

**SHOULD**
- Não bloquear colar senha (§44.7, Accessible Authentication); `autocomplete`
  correto; máscara que não impede entrada válida.
- Upload: validar tipo/tamanho no servidor, nunca confiar na extensão do cliente.

**VETADO**
- Validar **só** no cliente. Confiar no `disabled` do botão como "controle".
- Placeholder no lugar de `<label>` (§44.6).

> Regra de bolso: **servidor decide, cliente reflete.** Dado, autorização e
> validação têm sua verdade no servidor; o cliente é uma projeção rápida e
> acessível disso — nunca a autoridade.
