# Segurança de Frontend: Segredo, Sessão, Headers, XSS e Dependências

> Parte da skill **schematize-web**. Piso de segurança do frontend, **herdado e alinhado ao `schematize-go`** (§13.4/§38 de lá). Onde o back e o front se tocam (BFF, server action, route handler), valem as duas skills. Referências cruzadas (§N) são do corpo do schematize-web.

## Índice
- 43. Segurança de Frontend
  - 43.1 Segredo nunca no cliente
  - 43.2 Sessão e tokens
  - 43.3 Headers e CSP
  - 43.4 XSS e sanitização
  - 43.5 Open redirect, CSRF e navegação
  - 43.6 Autenticação/autorização como UX (decisão é no servidor)
  - 43.7 Higiene de dependência e SRI

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
- Logout invalida a sessão **no servidor** (não basta apagar cookie no cliente). Refresh token, quando houver, é rotativo com detecção de reuso (§14 do schematize-go).

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
- `tenant_id`, role, `user_id` vêm do **token verificado no servidor**, nunca de prop, query, header ou body controlados pelo cliente (§15 do schematize-go).
- Middleware de auth no front é conveniência de roteamento; o controle real está na borda do servidor que serve o dado.

**VETADO**
- Esconder dado sensível só com CSS/condicional de render (ele já foi pro cliente). Dado que o usuário não pode ver **não é enviado**.

### 43.7 Higiene de dependência e SRI

**MUST**
- **`npm audit` (ou equivalente) no CI**, falhando em `high`/`critical` sem ADR de aceite. SCA + Dependabot/Renovate.
- **Pin de versão** (lockfile commitado, sem range frouxo em dependência sensível). **Verificar nome** de toda dependência nova (typosquatting é real) e a licença (§13 do schematize-go: MIT/Apache-2.0/BSD/MPL-2.0/ISC ok; GPL/AGPL/SSPL/proprietária só com ADR).
- **SRI (`integrity` + `crossorigin`) em todo `<script>`/`<link>` de origem externa** (CDN). Sem SRI, um CDN comprometido injeta código no seu site.
- Minimizar script de terceiro (analytics, tag manager, widgets) — cada um é superfície de ataque e custo de performance (§45). O que entrar, entra com CSP e, quando possível, carregado de forma diferida e isolada.

**SHOULD**
- Self-host de fontes e de libs críticas quando viável (menos terceiros, melhor privacidade e CWV).
- Subresource e third-party revisados em PR como qualquer dependência.

> O front é a metade da aplicação que o atacante baixa inteira. Trate cada byte que vai pro cliente como público, cada input como hostil, e cada terceiro como um risco que você aceitou conscientemente.
