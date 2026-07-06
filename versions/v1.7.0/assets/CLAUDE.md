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
14. **Fluxo de ambientes — nada direto no servidor/site.** Toda mudança segue **dev local → teste local → GitHub → hml/preview → prd** (preview por PR é o "hml por mudança"). Nada pula etapa; nada vai direto pra hml/prd. **VETADO editar direto no site/servidor deployado**: mexer no build já publicado, hotpatch de HTML/JS/CSS no CDN/host, trocar asset "na mão" no bucket/edge. O site no ar é **imutável por edição manual**, recebe só **artefato promovido do git** (commit SHA, artefato imutável). Hotfix segue o mesmo fluxo, acelerado — urgência não autoriza mão no site publicado. Detalhe em `references/ops.md` (§1).
15. **Deploy só pelo pipeline (interface única) + independência multi-app.** Build/publicação/promoção/rollback/config passam pelo **pipeline de CI/CD** — nunca deploy manual ad-hoc (`scp`/`rsync`/upload do build, "arrastar `dist/`", asset solto no CDN). Não tem etapa no pipeline pra aquilo? **adiciona no pipeline**. O pipeline é **reproduzível**: o próprio usuário promove hml→prd e reverte em **um passo, sem depender da IA**. Rollback = promover o build anterior (imutável), nunca editar o site no ar. Em projeto **multi-app** (monorepo com vários sites/pacotes), build/subida é **paralela** = `nproc` e **independência é invariante**: se o paralelo falha, os apps não são independentes — corrigir isso é **prioridade máxima**, o pipeline **expõe** a colisão e **nunca serializa pra mascarar**. Detalhe em `references/ops.md` (§2, §5).
16. **Fonte única de config/env + build/deploy destrutivo do zero + isolamento por app.** A config parte de **uma fonte única de env** — no self-host o `/<app>/.env` global; no host gerenciado (Vercel/Netlify) as **env vars do projeto** no provedor — nunca config espalhada fora dela nem segredo no bundle. **Todo (re)deploy é build LIMPO do zero, a partir de git + env** (sem artefato/`.next`/`dist`/cache stale, **sem editar o site já publicado**): recria o build determinístico e reprodutível (mesmo commit+env → mesmo output). **"Destrutivo" é o BUILD, NUNCA os dados:** CMS/banco/uploads/conteúdo preservados (só mudam pelo fluxo próprio), jamais zerados por um redeploy. **Isolamento por app:** no self-host, user Linux + systemd/container hardened por app (em multi-app, isolamento por usuário — nunca `root`, nunca dois apps no mesmo user); no host gerenciado, a sandbox **imutável** do provedor — do seu lado, não furá-la. Detalhe em `references/ops.md` (§3, §4).
17. **Ícones, nunca emoji — e refino visual não é opcional.** **VETADO usar emoji na estrutura do site** (nav, botões, cards, features, bullets, títulos, empty states, status, setas) **a menos que o usuário peça**. Use **um icon set de verdade** (Lucide/Phosphor/Heroicons/Radix), SVG com `currentColor`, tamanho por token, `aria-hidden` quando decorativo — emoji renderiza diferente por SO, não herda cor/peso (quebra tema/dark) e destoa da marca. **Coesão (tokens) não basta pra parecer desenhado:** aplique as **13 alavancas de refino** (`references/design-refino.md`) — espaço generoso e assimétrico (respiro entre seções ≫ dentro), hierarquia com salto grande, **um** acento em neutros com tint, elevação por hairline **ou** sombra em camadas (nunca borda grossa/sombra dura), linha ≤75ch, grade/alinhamento, line-height por tamanho, raio aninhado, 4 estados por interativo, imagens tratadas, empty/loading(skeleton)/erro desenhados. Rode o **checklist de reprovação** antes de dar o layout por pronto. Refino é subtração e disciplina, dentro do budget de CWV (§45).

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
aplicável, **fluxo de ambientes respeitado** (promoção dev→local→github→hml/preview→prd,
deploy pelo pipeline — nada direto no site), **archive commitado**, CI verde e review
aprovado. Detalhe em `references/qualidade.md` (§35, §28.1).

## Qualidade de código e índice (sempre)

- **Arquivos ≤ 300 linhas.** Maior → micro-componentes/hooks com nome que explica a
  intenção. Componente de responsabilidade única; lógica em hooks, não no JSX.
- **Comente TODO componente/hook/função** com contexto: **O quê** e **Onde** (quem monta /
  em que fluxo), além de estado/efeitos. Alimenta o índice (§6, §39).
- **Índice atualizado no mesmo PR** (§39), em **`<projeto>_archive/index/`** (nunca no root): `INDEX_GLOBAL.md` (páginas/rotas/áreas) à mão e
  `INDEX_COMPONENTS.md` (componente/hook → o quê → onde → arquivo:linha) gerável via
  `scripts/build-index.mjs`. Índice é fonte da verdade: consulte ANTES de criar, pra não duplicar.
  **Exaustivo:** uma entrada **por** componente/hook/função/rota (`nº entradas == nº unidades`; `/web-index` reprova se faltar) e um **grafo** (rotas→páginas→componentes + consumo de API, Mermaid + adjacência) — o índice **enumera**, não resume.
- **Todo MD gerado mora no archive, nunca no root** (§28): MAPA, índices, planos,
  relatórios, handoffs, checkpoints → `<projeto>_archive/<área>/`. O root fica limpo (código,
  config e os MDs de projeto mantidos à mão: README, `CLAUDE.md`, LICENSE). Antes de gravar
  um `.md`, o caminho começa com `<projeto>_archive/`.

## Gestão de contexto (Claude Code — sessões longas)

Ao ver "⚠ LIMITE" no status line, ou ao se aproximar do teto da janela: **PARE e, ANTES de
compactar**, faça o handoff arquivado (§34.1, §28):

1. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-context.md` — estado, decisões, arquivos
   tocados, onde parou.
2. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-checklist.md` — **FEITO vs EM ABERTO**.
3. Só então rode `/compact`.

Detalhe e hooks: `references/contexto-claude-code.md`.
