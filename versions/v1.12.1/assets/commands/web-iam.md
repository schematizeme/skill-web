---
description: schematize-web — força/audita/scaffolda o IAM (front de auth próprio em auth.<domain>, fluxos de login/2FA/passkey, view de dispositivos, logout irreversível) do lado do cliente, ou audita um authfront existente
argument-hint: "[audit | scaffold]"
---

Governe o lado **cliente/front** do IAM da casa pelo padrão (`references/iam.md`, recorte
frontend). Plan-first: **audita, mostra o plano, pede aprovação, então executa.** Use este
comando para **forçar/auditar só a parte de front do IAM** — o `<projeto>_authfront`, os
fluxos de login/2FA/passkey, o nudge de email secundário, a view de dispositivos e o
logout irreversível. O backend/serviço de auth, motor ReBAC e migração ficam no `/eng-iam`
(schematize-engineering) e no `schematize-go`.

> **Regra suprema deste comando:** o cliente é **UX**; a decisão e o enforcement são
> **server-side**. Nada aqui "protege" — o front **conduz o fluxo**, o servidor **impõe**.

## 0. Modo
- `audit` — varre o front e reporta o gap contra o piso IAM-cliente (checklist §iam do front).
- `scaffold` — scaffolda o `<projeto>_authfront` e/ou as telas/fluxos de auth do cliente.

## 1. Topologia primeiro (inegociável)
Confirme/scaffolde que o auth tem **front próprio, app à parte** (`references/iam.md` §1):
- **`<projeto>_authfront`** (Next.js ou Astro, TS strict) servido em **`auth.<domain>`** —
  **VETADO** embutir login/cadastro/2FA no bundle do site principal.
- Cliente delega por **OIDC/OAuth2.1 + PKCE**: redireciona a `auth.<domain>`, `state`/`nonce`
  e `code_verifier` por **CSPRNG**; a **troca de code por token é no servidor** (BFF/route
  handler) — **`client_secret` nunca no bundle**, PKCE mesmo em SPA/public client.

## 2. Identidade e nudge na UI
- **Usuário nunca loga pelo ID interno**; email/telefone são **identificadores com estado
  de verificação** na tela de conta (N por usuário, verificado só depois de verificar).
- **SSO força enrolar recuperação local** (email de recuperação + códigos de backup);
  account-linking com **confirmação explícita** (anti-takeover).
- **Nudge de email secundário:** com 1 email, sugere adicionar outro — **detecta o provedor**
  (gmail / hotmail-outlook / yahoo / próprio) e **recomenda um provedor DIFERENTE** + **"i"
  com tooltip acessível** (foco por teclado, `aria-describedby`): *"Um segundo email, de
  preferência em outro provedor, garante que você não perca o acesso…"*. Sugestão, não obrigação.

## 3. Fatores no navegador (≥2 sempre)
- **Passkey/WebAuthn no núcleo** via `navigator.credentials.create()/get()` com options do
  **servidor** (challenge/`user.id` como `ArrayBuffer`), **feature-detect** + fallback;
  `rp.id` casa com `auth.<domain>`.
- **Seletor de método:** com vários fatores enrolados, **lista todos e o usuário escolhe**
  (a lista vem do servidor); OTP com `autocomplete="one-time-code"`, reenvio em backoff.
- **Senha por padrão** (força no cliente é só dica; verificação argon2id+HIBP no servidor),
  **opcional no seletor de modos**. **2º fator é nudge + step-up just-in-time**, **nunca muro pré-login** (senha+Email OTP já é o 2FA baseline; barrar o acesso por falta de fator forte é bug de bootstrap vetado).
- **Invariante de troca (UI):** para mutar o fator X, a tela pede **Y≠X no maior AAL**;
  avisa que todos os canais serão notificados; remover último fator forte = **atraso
  cancelável**. Recuperação **≥ força do login** (a UI nunca oferece reset que pule o 2º fator).

## 4. Autorização no cliente = UX
- **`can()`/`isAdmin` no React só PINTA a tela** (esconde/desabilita) — **nunca** controla
  acesso. `role`/`tenant_id`/`user_id` **nunca** autorizam a partir de prop/query/storage/JWT
  decodificado no cliente. **Dado que o usuário não pode ver não é buscado/enviado** (esconder
  ≠ proteger). Toda ação sensível é **re-checada no servidor** (deny-default).

## 5. Sessão / dispositivos / logout (no front)
- **Token em cookie `HttpOnly`+`Secure`+`SameSite`**, **NUNCA** em `localStorage`; o front
  não manuseia token. **Sessão 7d por padrão; "confiar neste dispositivo?" → 90d** (refresh
  silencioso — nada de "15 min e é chutado"). **Step-up UX** (passkey/push) em ops sensível.
- **View de dispositivos:** lista ativos (rótulo amigável, IP/geo, último uso), **remover
  um** + **"sair de todos"** — cada ação é pedido ao servidor.
- **Botão "Sair" visível → chama o revoke e SÓ ENTÃO limpa local:** o kill é **server-side**
  e **irreversível** (revoga refresh+família, apaga sessão, `jti` na denylist, desassocia
  push). **VETADO** tratar `document.cookie = ''`/limpar storage como logout — se o revoke
  falha, é erro, não "deslogou".

## 6. Testes (dispare o gate)
Rode/priorize: **e2e (Playwright)** dos fluxos (onboarding email→verifica→1º→2º fator, login
com seletor, passkey por virtual authenticator, nudge+tooltip, view de dispositivos, **logout
que de fato invalida** — reusar cookie após "Sair" = 401); **a11y (axe)** por tela; **gate
anti-vazamento** (token em `localStorage`, segredo em `NEXT_PUBLIC_*`/`VITE_*`, authz decidida
no cliente). Cross-tenant/priv-esc do backend ficam na `schematize-pentest` (`/pentest-authz`).

## 7. Saída
Grave o plano/relatório em `<projeto>_archive/` (§28): topologia (authfront é app à parte?),
gaps do checklist IAM-cliente (`references/iam.md`), plano por tela/fluxo. Confirme: front de
auth separado em `auth.<domain>`? OIDC/PKCE (code trocado no servidor)? onboarding com 2º
fator obrigatório + seletor de método + passkey? nudge com detecção de provedor + tooltip?
token só em cookie HttpOnly (nunca localStorage)? view de dispositivos + logout irreversível
via revoke server-side? nenhuma decisão de authz no cliente (enforcement server-side)?
