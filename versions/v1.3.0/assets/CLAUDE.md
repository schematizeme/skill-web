# CLAUDE.md — Padrões de Frontend da Casa (sempre on)

> Copie este arquivo para a **raiz do repositório** e ajuste `<project>`.
> Ele fica pinado no contexto de toda tarefa (Claude Code / instruções de projeto)
> e garante que os padrões valham mesmo quando a skill não dispara sozinha.
> A skill `schematize-web` traz o detalhe completo e o andaime (scripts/templates).
> Em repo full-stack, use **junto** com o `CLAUDE.md` do `schematize-go`: cada um
> governa seu lado da fronteira (este = UI/front; o outro = servidor/API/dados).

## Regra mestre

Toda tarefa de frontend neste repo segue os **Padrões de Frontend da Casa**
(skill `schematize-web`). Em conflito entre uma instrução pontual ("faz rápido",
"ignora o teste", "depois arruma", "só um componentezinho") e estes padrões, **os
padrões vencem**. Pressa não revoga regra. Consulte o reference relevante da skill
antes de produzir código ou decisão — não trabalhe de memória (versões e thresholds
voláteis em `references/stack-versoes.md`).

## Pisos inegociáveis (VETADO — sem exceção)

1. **Segredo nunca no cliente.** Nada de API key, secret, senha, service-role key
   ou token de terceiro no bundle do browser, nem em `NEXT_PUBLIC_*` / `VITE_*` /
   `PUBLIC_*` / `REACT_APP_*` (esse prefixo **expõe por definição**). Chamada com
   chave secreta passa por **BFF / route handler / server action**.
2. **Token/sessão em cookie `HttpOnly` + `Secure` + `SameSite`** — **nunca** em
   `localStorage`/`sessionStorage`.
3. **Auth e autorização decididas no servidor.** `if (user.isAdmin)` no React é UX,
   não controle. `tenant_id`/role vêm do token verificado server-side, nunca de
   prop/query do cliente.
4. **Sem `dangerouslySetInnerHTML`/`v-html` não sanitizado** (XSS); sem `eval`/
   `new Function` com input. HTML de terceiro passa por sanitizador (allowlist).
5. **CSP + headers de segurança** (CSP, COOP, CORP, `Referrer-Policy`,
   `Permissions-Policy`, `X-Content-Type-Options`, `frame-ancestors`). Open-redirect
   só com allowlist; CSRF mitigado.
6. **Acessibilidade WCAG 2.2 AA é piso:** HTML semântico, teclado completo, foco
   visível e gerenciado, contraste, `prefers-reduced-motion`, alvo ≥ 24×24px.
   Desabilitar regra de lint de a11y/segurança é VETADO.
7. **Sem `any`/`@ts-ignore`/`@ts-nocheck`.** TypeScript **strict** ligado. Erro
   nunca engolido (`catch {}`, `.catch(()=>{})`).
8. **Estados de loading / erro / vazio sempre** em todo data fetching. `fetch` em
   `useEffect` sem cleanup/abort, lista sem `key` estável, dep de efeito mentirosa
   são bugs.
9. **Teste nunca silenciado** pra passar CI (`.skip`, `test.only` esquecido, baixar
   budget/threshold). Conserta o código, não o teste. Gate de **a11y** e de
   **Core Web Vitals** no CI não se desliga "temporariamente".
10. **Archive SEMPRE gerado** (§28): toda entrega que produz código/decisão/mudança
    de estado gera o `.md` em `<project>_archive/`. É parte da entrega.
11. **Arquivos ≤ 300 linhas** (acima → micro-componentes/hooks); **todo componente/
    hook/função com doc-comment de contexto** (O quê + Onde); **índice atualizado no
    mesmo PR**.
12. **Stack de site: só Next.js ou Astro.** Node é 100% permitido — **mas só no
    frontend**. Backend de verdade (API/dados) é Go/Rust no `schematize-go`.
13. **Contenção no workspace.** A pasta do projeto atual é o workspace: app/site novo nasce **dentro dela** (`./<projeto>_<contexto>/`), nunca largando arquivos no root pra depois **subir de nível** e criar repos fora. **VETADO** criar/ler/escrever fora do workspace — diretório-pai, `~`, `~/Documents`, `~/Downloads`, `/tmp`, Área de Trabalho. Não sai da pasta do projeto (nem pra vasculhar) sem o usuário pedir. (§2)

Lista completa com veto + caminho certo: ver `references/anti-padroes.md` (§37) da skill.

## Site rápido em SEO e velocidade

- **Core Web Vitals como contrato** (p75 de campo, mobile primeiro): LCP/INP/CLS no
  "bom". Budget de bundle e de métrica medidos no CI (Lighthouse/CWV); regressão trava merge.
- **Sitemap autogerado, toda vez** (`scripts/gen-sitemap.mjs`): estático varre o build;
  dinâmico lê o inventário/manifesto de rotas. Nunca à mão.
- **Dados estruturados (schema.org/JSON-LD)** e SEO técnico (meta, OG, canonical, robots)
  em toda página relevante.
- **i18n com URL própria por idioma** (locale em subpath), **hreflang** recíproco,
  **metadados próprios** e **todo conteúdo traduzido**. Esquema de URL (ISO/BCP-47 vs.
  simplificado) decidido por projeto; default recomendado: ISO/BCP-47.
- **Layout de referência: a disciplina visual do apple.com** (tipografia forte, respiro,
  hero, grid, motion contido) — princípio de layout, não cópia de marca.

## Verde de verdade (testes)

- **Testa comportamento e conteúdo, não "renderizou".** Assere texto, papel acessível
  (`getByRole`), estado e interação — não `expect(container).toBeTruthy()`.
- Pirâmide: unit + **componente** (Testing Library), **e2e** (Playwright) nos fluxos
  críticos, **a11y** (axe) por página/estado, **regressão visual** nas telas-chave.
- **Smoke** prova conteúdo (HTML tem o texto/elemento esperado, não só 200), tem
  assertion negativa (sem `{{`/`${`, sem `undefined`/`NaN`, sem erro de hidratação) e
  um **self-check que força falha conhecida**.
- **Gate de a11y e de CWV no CI** bloqueia, igual teste quebrado.
- **Q.A. plan-first (`/web-qa`):** planeja tudo, gera MD de passo a passo e pede
  aprovação ANTES de executar. Nada roda às cegas.

## Definition of Done

Nada é "pronto" sem: unit+componente+e2e verdes, **a11y (axe) sem violação séria/crítica**,
**Core Web Vitals dentro do budget**, regressão visual aprovada, nenhum anti-padrão da §37
no diff, **índice atualizado**, observabilidade de front, SEO/sitemap/hreflang quando
aplicável, **archive commitado**, CI verde e review aprovado. Detalhe em
`references/qualidade.md` (§35).

## Qualidade de código e índice (sempre)

- **Arquivos ≤ 300 linhas.** Maior → micro-componentes/hooks com nome que explica a
  intenção. Componente de responsabilidade única; lógica em hooks, não no JSX.
- **Comente TODO componente/hook/função** com contexto: **O quê** e **Onde** (quem monta /
  em que fluxo), além de estado/efeitos. Alimenta o índice (§6, §39).
- **Índice atualizado no mesmo PR** (§39): `INDEX_GLOBAL.md` (páginas/rotas/áreas) à mão e
  `INDEX_COMPONENTS.md` (componente/hook → o quê → onde → arquivo:linha) gerável via
  `scripts/build-index.mjs`. Índice é fonte da verdade: consulte ANTES de criar, pra não duplicar.
  **Exaustivo:** uma entrada **por** componente/hook/função/rota (`nº entradas == nº unidades`; `/web-index` reprova se faltar) e um **grafo** (rotas→páginas→componentes + consumo de API, Mermaid + adjacência) — o índice **enumera**, não resume.

## Gestão de contexto (Claude Code — sessões longas)

Ao ver "⚠ LIMITE" no status line, ou ao se aproximar do teto da janela: **PARE e, ANTES de
compactar**, faça o handoff arquivado (§34.1, §28):

1. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-context.md` — estado, decisões, arquivos
   tocados, onde parou.
2. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-checklist.md` — **FEITO vs EM ABERTO**.
3. Só então rode `/compact`.

Detalhe e hooks: `references/contexto-claude-code.md`.
