# Segurança de Frontend: Segredo, Sessão, Headers, XSS e Dependências

> Parte da skill **schematize-web**. Piso de segurança do frontend, **herdado e alinhado à base `schematize-engineering`** (§13.4/§38 de lá). Onde o back e o front se tocam (BFF, server action, route handler), valem as duas skills. Referências cruzadas (§N) são do corpo do schematize-web.

## Índice
- 43. Segurança de Frontend
  - 43.1 Segredo nunca no cliente
  - 43.2 Sessão e tokens
  - 43.3 Headers e CSP
  - 43.4 XSS e sanitização
  - 43.5 Open redirect, CSRF e navegação
  - 43.6 Autenticação/autorização como UX (decisão é no servidor)
  - 43.7 Higiene de dependência e SRI
  - 43.8 Envio de e-mail e efeito externo (preview é NÃO-produção)
  - 43.9 Quando a mesma tela roda FORA do browser: webview e Electron/Tauri

---

## 43. Segurança de Frontend

> Postura: **assume-hostil**. Todo dado que vem do usuário, da URL, de `postMessage`, de terceiro ou de storage é tratado como hostil até prova de sanitização. O navegador é território do atacante — nada de confiança lá.

### 43.1 Segredo nunca no cliente

**VETADO — sem exceção, sem ADR**
- **Qualquer segredo no bundle que vai pro browser.** API key privada, secret de JWT, senha, service-role key (Supabase/Firebase admin), token de pagamento, chave de terceiro — **nada** disso entra em código que o cliente baixa. O navegador não guarda segredo.
- **Prefixar segredo com `NEXT_PUBLIC_`, `VITE_`, `PUBLIC_` ou equivalente.** Esse prefixo **expõe a variável publicamente por definição** — use só para valor que poderia estar num outdoor (URL de API pública, id de analytics público, chave *publishable* desenhada pra ser pública).
- **Chamar API de terceiro com chave secreta direto do browser.** Toda chamada que usa segredo passa por um **BFF / route handler / server action** server-side, que segura a chave e expõe só o necessário.

**MUST**
- Segredo mora em variável de ambiente **sem** prefixo público, lida apenas em código server-side. Em build estático (Astro), garanta que o segredo não vaza pro HTML/JS gerado.
- `.env` real **nunca** commitado; `.env.example` sem valores. Secret scan no pipeline.

> "Bota a chave no `NEXT_PUBLIC_` pra funcionar" não é solução, é vazamento agendado. Se o cliente pode ler, o atacante já leu.

### 43.2 Sessão e tokens

**MUST**
- **Token de sessão/auth em cookie `HttpOnly` + `Secure` + `SameSite=Lax|Strict`.** `HttpOnly` impede JS (e portanto XSS) de ler; `Secure` exige HTTPS; `SameSite` corta CSRF na maioria dos casos.
- **`localStorage`/`sessionStorage` NUNCA guardam token/sessão.** Qualquer XSS lê todo o storage — token lá é token roubável. (VETADO — §37.)
- Logout invalida a sessão **no servidor** (não basta apagar cookie no cliente). Refresh token, quando houver, é rotativo com detecção de reuso (§14 da `schematize-engineering`).

### 43.3 Headers e CSP

**MUST** — toda resposta de documento configura:
- **Content-Security-Policy** restritiva: sem `unsafe-inline`/`unsafe-eval` (use nonce/hash pra inline necessário). Em Astro 6+, há CSP nativo (hashes automáticos); em Next, configure no middleware/headers.
- **`frame-ancestors`** (anti-clickjacking; complementa/substitui `X-Frame-Options`).
- **`X-Content-Type-Options: nosniff`**, **`Referrer-Policy`** (ex.: `strict-origin-when-cross-origin`), **`Permissions-Policy`** (desliga câmera/mic/geo não usados).
- **COOP** (`Cross-Origin-Opener-Policy`) e **CORP** (`Cross-Origin-Resource-Policy`) coerentes com o que a página precisa isolar.
- **HSTS** no host (TLS 1.2+; redirect de HTTP pra HTTPS).

**SHOULD**
- CSP em modo `report-only` primeiro, com endpoint de report, antes de impor — pra não quebrar a página em produção.

### 43.4 XSS e sanitização

**VETADO**
- **`dangerouslySetInnerHTML` (ou `set:html` do Astro, ou `innerHTML`) com conteúdo não sanitizado.** HTML de usuário/terceiro/CMS passa por sanitizador com **allowlist** de tags/atributos (ex.: DOMPurify no servidor). Sanitização frouxa por regex não conta.
- **`eval`, `new Function`, `setTimeout`/`setInterval` com string** contendo qualquer parte vinda de input.
- Construir URL `javascript:` ou injetar `<script>`/handler a partir de input.

**MUST**
- Confiar no **escape automático do framework** (JSX/Astro escapam por padrão) — o perigo é só quando você fura isso de propósito (item acima).
- Sanitizar **antes de armazenar e ao renderizar** (defense in depth). Markdown de usuário é renderizado por lib que escapa HTML embutido, não concatenado cru.

### 43.5 Open redirect, CSRF e navegação

**MUST**
- **Redirect/`next`/`returnTo` só com allowlist.** `?next=https://evil.com` que o app obedece é open redirect. Aceite apenas caminhos relativos internos conhecidos, ou origens numa allowlist.
- **CSRF mitigado:** cookie `SameSite` + token anti-CSRF em mutações sensíveis quando a sessão é por cookie. Server action/route handler de escrita verifica origem/refer e/ou token.
- **`target="_blank"` com `rel="noopener noreferrer"`** (evita `window.opener` hijack e vazamento de referrer).
- Validar `postMessage` por `origin` (allowlist) antes de confiar no payload.

### 43.6 Autenticação/autorização como UX (a decisão é no servidor)

**MUST**
- **Toda decisão de acesso é server-side.** `if (user.isAdmin)` no React **esconde** o botão (UX) — não **protege** o recurso. A rota/route handler/server action **re-verifica** a autorização no servidor a cada request.
- `tenant_id`, role, `user_id` vêm do **token verificado no servidor**, nunca de prop, query, header ou body controlados pelo cliente (§15 da `schematize-engineering`).
- Middleware de auth no front é conveniência de roteamento; o controle real está na borda do servidor que serve o dado.

**VETADO**
- Esconder dado sensível só com CSS/condicional de render (ele já foi pro cliente). Dado que o usuário não pode ver **não é enviado**.

### 43.7 Higiene de dependência e SRI

**MUST**
- **`npm audit` (ou equivalente) no CI**, falhando em `high`/`critical` sem ADR de aceite. SCA + Dependabot/Renovate.
- **Pin de versão** (lockfile commitado, sem range frouxo em dependência sensível). **Verificar nome** de toda dependência nova (typosquatting é real) e a licença (§13 da `schematize-engineering`: MIT/Apache-2.0/BSD/MPL-2.0/ISC ok; GPL/AGPL/SSPL/proprietária só com ADR).
- **SRI (`integrity` + `crossorigin`) em todo `<script>`/`<link>` de origem externa** (CDN). Sem SRI, um CDN comprometido injeta código no seu site.
- Minimizar script de terceiro (analytics, tag manager, widgets) — cada um é superfície de ataque e custo de performance (§45). O que entrar, entra com CSP e, quando possível, carregado de forma diferida e isolada.

**SHOULD**
- Self-host de fontes e de libs críticas quando viável (menos terceiros, melhor privacidade e CWV).
- Subresource e third-party revisados em PR como qualquer dependência.

### 43.8 Envio de e-mail (e todo efeito externo) a partir do front

> **Normativa canônica:** `schematize-engineering` → `references/efeitos-externos.md` (domínio de
> teste em rota nula, sink por default, guard fail-closed, cap por execução, as 5 condições da
> exceção). Aqui está só o **recorte de frontend** — porque o front **também dispara**: server
> action, route handler e BFF mandam e-mail tanto quanto um backend, e o **preview deploy** é o
> lugar onde isso mais escapa.

**O ponto novo não é a chave — é o ENVIO.** A §43.1 já veta chave de provedor no bundle e em
`NEXT_PUBLIC_*`/`VITE_*`/`PUBLIC_*`. Mas **a chave corretamente server-side não protege ninguém**:
com ela no lugar certo, um form de contato rodando em preview/dev continua **entregando e-mail de
verdade em gente de verdade**. Bounce e complaint em massa **queimam o IP e o domínio** e derrubam
o transacional de **produção** — inclusive o **OTP de login** (`references/iam.md`) — com semanas de
warm-up e **utilidade zero**.

**MUST** — toda server action / route handler / BFF que dispara e-mail (contato, newsletter,
convite, **reset de senha**, **magic link**, notificação), SMS, push, webhook de terceiro ou
cobrança:
- **Provider resolvido no servidor, por ambiente, uma vez na composição** — nunca por chamador,
  nunca por flag vinda do cliente. Fora de `prd`, o **default é o SINK** (Mailpit/log com API HTTP
  pro e2e ler a caixa).
- **Guard deny-by-default DENTRO do provider** (o chamador esquece; o provider não): destinatário
  fora do domínio de teste com `env != prd` → **erro acionável**, nunca warning nem no-op silencioso.
- **Cap por execução** (`MAIL_MAX_PER_RUN`, default 50) + circuit breaker que **aborta**.
- **Fail-closed:** ambiente ausente ou ilegível ⇒ assume **não-produção**.

#### Preview/branch deploy é NÃO-PRODUÇÃO (e é onde escapa)

Preview de PR na Vercel/Netlify/Cloudflare Pages **parece produção**: URL do mesmo projeto, build
idêntico e — o veneno — **as mesmas env vars herdadas do projeto**. Por isso o piso é explícito:

| Escopo | Discriminador (Vercel) | Provider de envio | Chave do provedor |
|---|---|---|---|
| Production | `VERCEL_ENV=production` | provedor real | **a única** que existe aqui |
| Preview (PR/branch) | `VERCEL_ENV=preview` | **SINK** | sandbox (ou nenhuma) |
| Development (local, `vercel dev`) | `VERCEL_ENV=development` | **SINK** | sandbox (ou nenhuma) |
| indeterminado | ausente/ilegível | **SINK** (fail-closed) | nenhuma |

- **VETADO discriminar por `NODE_ENV` sozinho.** No build de preview `NODE_ENV` também é
  `production` — é exatamente esse o erro clássico que entrega e-mail real de um PR. Use
  **`VERCEL_ENV`**; na Netlify, **`CONTEXT`** (`production`/`deploy-preview`/`branch-deploy`); no
  Cloudflare Pages, o branch (`CF_PAGES_BRANCH`) contra a branch de produção.
- **Env de Preview e de Development apontam pro sink**, declaradas **por escopo** no provedor
  (§56). A **chave de produção do provedor existe só no escopo Production** — se ela está marcada
  "todos os ambientes", já está errado.
- **Preview deploy com credencial de envio de produção é incidente**, não conveniência: vira
  rollback de env + rotação de chave, não "depois eu separo".

#### Endpoint público de envio: rate-limit, anti-bot e destinatário fixo

Form de contato/newsletter aberto na internet é **bomba de e-mail de graça** para qualquer um — e,
sem cuidado, vira **relay de spam** e abuso de recurso (custo por envio, reputação queimada por
terceiro).

**MUST**
- **Rate-limit por IP + por destinatário/identidade** e **cap global por janela** no servidor
  (nunca no cliente). Estourou → 429, não envio silencioso.
- **Anti-bot** no endpoint: Turnstile/hCaptcha **verificado server-side** + **honeypot** +
  time-to-submit mínimo. Validação server-side do payload (§51) é pré-requisito, não substituto.
- **O destinatário NUNCA vem do corpo da requisição.** Form de contato manda para a **caixa da
  casa**, fixada no servidor; `to`/`cc`/`bcc` vindos do cliente = **relay aberto**. O que o usuário
  digitou entra como **corpo de texto escapado** (e `Reply-To` só depois de validado), nunca como
  header cru — `\r\n` em campo de header é **header injection**.
- **Newsletter só com double opt-in** (confirmação por link assinado e expirável); a própria
  confirmação conta no cap. Lista sem opt-in confirmado é hard bounce e spam trap esperando.

#### Endereços sintéticos no front

Fixture, seed, persona de demo, e2e (Playwright) e **screenshot de teste visual** usam **só** o
domínio de teste em rota nula — `test.<domain>` (null MX + SPF `-all` + DMARC `p=reject`) ou TLD
reservado (`.test`/`.invalid`/`.example`). **VETADO** `@gmail.com`/`@hotmail.com`, domínio de
cliente/terceiro, e-mail de pessoa real (**inclusive o seu**) e o domínio de **produção**. O
detalhe (forma canônica do endereço, DNS, as 4 camadas, a exceção com ADR) está no canônico — não
se reescreve aqui.

**Regra de bolso do §43.8: se o ambiente não provou que é `prd`, ele não entrega.** Chave no
servidor resolve **vazamento**; só o sink por default resolve **ENVIO**.

> O front é a metade da aplicação que o atacante baixa inteira. Trate cada byte que vai pro cliente como público, cada input como hostil, e cada terceiro como um risco que você aceitou conscientemente.

### 43.9 Quando a mesma tela roda FORA do browser: webview e Electron/Tauri

O piso desta seção foi escrito para o sandbox do navegador. Quando a **mesma tela** é embarcada
num cliente nativo, o sandbox muda — e o piso **não afrouxa; endurece**.

**Webview de app nativo (`schematize-mobile`).** O app embute uma tela desta stack (checkout,
onboarding, área logada). O que viaja junto, sem desconto:

- **Token continua em cookie `HttpOnly`.** VETADO passar token pela **bridge JS** do webview, por
  `postMessage`, por query string de deep link ou guardá-lo em `localStorage` "porque o app já
  está autenticado". O webview é um browser com dono diferente, não uma zona confiável.
- **Login NÃO acontece dentro do webview.** OAuth/OIDC de app público abre no **navegador do
  sistema** (Custom Tabs / ASWebAuthenticationSession) e volta por Universal/App Link verificado —
  a regra é da `schematize-mobile`, e esta skill renderiza o outro lado dela.
- **CSP e `frame-ancestors` continuam valendo.** Um webview sem CSP é a mesma página sem CSP.
- **Nada de `file://` com privilégio.** Conteúdo remoto não roda em origem local.

**Electron/Tauri (`schematize-desktop`) — onde XSS vira RCE local.** No browser, uma injeção de
HTML rouba sessão. Num cliente nativo com ponte para o sistema, a **mesma** injeção executa código
na máquina do usuário: lê `~/.ssh`, escreve no autostart, chama `exec`. A diferença de severidade
entre `dangerouslySetInnerHTML` no site e no app empacotado é **de categoria**, não de grau.

- **Electron:** `contextIsolation: true` e `nodeIntegration: false` — sem exceção. A ponte é um
  `contextBridge` com **allowlist explícita de funções**, nunca `ipcRenderer` exposto cru.
- **Tauri:** allowlist mínima de comandos; nada de `shell.open` genérico nem `fs` com escopo amplo.
- **CSP sem `unsafe-inline`/`unsafe-eval`** no app empacotado, e `will-navigate`/`new-window`
  travados numa allowlist de origem.
- **Segredo no bundle é segredo PUBLICADO.** O cliente nativo é distribuído: qualquer chave nele
  está nas mãos de quem baixou. O piso 43.1 vale em dobro.
- **Auto-update assinado** e a superfície de atualização é da `schematize-desktop`.

> Regra de bolso: **se a tela pode ser embarcada, o piso é o do host mais perigoso** —
> `schematize-desktop` > `schematize-mobile` > browser.
