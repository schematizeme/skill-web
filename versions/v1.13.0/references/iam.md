# IAM — Identidade e Autorização no cliente/front (piso inegociável)

Recorte **frontend/cliente** do piso de IAM da casa. O padrão-mãe (agnóstico de
linguagem, com o serviço de auth, motor ReBAC, sessão, migração) é
`schematize-engineering/references/iam.md`; o backend (emissão/validação de token,
JWKS, PDP/PEP) é `schematize-go`. Aqui trata-se do que o **navegador e o front de auth**
fazem: o **front de auth próprio**, os **fluxos de login/2FA/passkey**, o **nudge de
email secundário**, a **view de dispositivos** e o **logout irreversível** — sempre
lembrando que **o cliente é UX; a decisão e o enforcement são server-side.**

Princípios-âncora no cliente: **o front de auth é um app à parte** (nunca embutido no
site principal); **token nunca no `localStorage`** (cookie `HttpOnly`); **nenhuma
decisão de acesso é tomada no cliente** (checagem no React/JSX é só para pintar a UI);
**logout dispara um kill server-side irreversível**, não um `document.cookie = ''`.

## 1. Topologia no cliente — o front de auth é um APP SEPARADO

- **A autenticação tem front próprio**, o `<projeto>_authfront` (Next.js ou Astro,
  TypeScript strict), servido em **`auth.<domain>`**. **VETADO** embutir telas de
  login/cadastro/2FA no bundle do site principal (`app.<domain>`, landing, dashboard).
  Comprometer o XSS do site principal **não** pode alcançar o fluxo de credencial.
- **O site principal e todo cliente delegam por OIDC/OAuth2.1 + PKCE:** ao precisar de
  sessão, **redireciona o browser para `auth.<domain>`** (Authorization Code + **PKCE**
  — `code_verifier`/`code_challenge`, `state`, `nonce`), o usuário autentica lá, e o
  callback volta com o code que o **BFF/route handler** troca por token **no servidor** —
  o `client_secret` (quando houver) e a troca **nunca** vivem no browser.
- **PKCE é obrigatório mesmo em SPA/public client:** sem `client_secret` no bundle, com
  `code_verifier` gerado por **CSPRNG** (`crypto.getRandomValues`, nunca `Math.random()`).
- **O front de auth só fala com o serviço de auth** (o IdP da casa). Nenhuma chave de
  assinatura, segredo de provider (Resend/Twilio/WebAuthn RP secret) ou credencial de
  verificação aparece no bundle — tudo server-side no `<projeto>_auth_<lang>`.

## 2. Modelo de identidade na UI

- **O usuário nunca digita/vê o ID interno** (ULID/UUIDv7 opaco) como login. **Email e
  telefone são *identificadores*, não ID** — a UI trata cada um com seu **estado de
  verificação** (badge "verificado"/"pendente", reenvio de verificação).
- **N identificadores por usuário na tela de conta:** lista de emails, telefones,
  identidades SSO, passkeys — todos gerenciáveis, com o verificado destacado. **Ter mais
  de um email é incentivado** pela UI (ver o nudge, §3).
- **Identificador só vale verificado:** a UI não deixa logar/recuperar por um email/telefone
  ainda não verificado — mostra o passo de verificação, não um atalho.
- **SSO nunca é botão único:** ao cadastrar por "Entrar com Google/Apple", a UI **força
  enrolar ≥1 fator de recuperação local** (email de recuperação + baixar códigos de
  backup) antes de liberar o acesso pleno — provedor banido ≠ conta perdida.
- **Account-linking com confirmação explícita:** SSO chegando com email já verificado em
  outra conta → tela de confirmação (linkar vs. bloquear), nunca link silencioso.

### Nudge de email secundário (anti-brick) — detalhe de front

Com só **1 email** cadastrado, a tela de conta **sugere adicionar um secundário** (card
de sugestão, dispensável — **sugestão, não obrigação**):

- **Detecção de provedor do email atual** (parse do domínio após o `@`): **gmail**
  (`gmail.com`/`googlemail.com`), **hotmail-outlook** (`hotmail.*`/`outlook.*`/`live.*`/
  `msn.com`), **yahoo** (`yahoo.*`/`ymail.com`), senão **próprio/corporativo**.
- **Recomenda um provedor DIFERENTE:** o texto sugere que o secundário seja de **outro
  provedor** que não o detectado (ex.: atual gmail → "prefira um email que não seja
  Gmail"), reduzindo o risco de perder os dois de uma vez por brick de um provedor.
- **"i" com tooltip no hover** ao lado da sugestão — acessível (foco por teclado +
  `aria-describedby`, não só `title`), com o texto:
  > *"Um segundo email, de preferência em outro provedor, garante que você não perca o
  > acesso caso perca acesso a este email."*
- Adicionar o secundário dispara a **verificação** dele e, por ser mudança de
  identificador, exige verificação **no maior AAL disponível** (fator forte se já houver;
  senão o baseline — senha + Email OTP), §4 invariante de troca.

**Nudge de fator forte (anti-perda + menos atrito) — irmão do nudge de email:** quem está só
no 2FA baseline (senha + Email OTP) vê um card **dispensável** sugerindo enrolar **passkey/app**
— não para "desbloquear o acesso" (já tem), mas para **não depender só do email** e **passar
liso** em ações sensíveis (sem step-up por email toda vez). Texto honesto: *"Você já está
protegido com senha + código por email. Adicionar uma passkey ou app deixa sua conta mais
forte e evita pedir código a cada ação sensível."* **Sugestão, nunca bloqueio.**

## 3. Fatores no navegador — passkey/WebAuthn, seletor de método

Classificação de força (AAL — NIST 800-63B) definida no backend; a UI **expõe e escolhe**:

| Tier | Fatores | UX no cliente |
|---|---|---|
| **Alto (phishing-resistant)** | **Passkey/WebAuthn (núcleo)**, chave FIDO2, push aprovado | `navigator.credentials`; exigido em ops sensíveis (step-up) |
| **Médio** | TOTP (app autenticador), senha + posse | login + 2º fator |
| **Baixo (fallback)** | **Email OTP**, **SMS/voz** | sempre disponível; **não** autoriza ação sensível sozinho |

- **Passkey/WebAuthn no navegador é núcleo (não roadmap):**
  - Registro: o servidor devolve as `PublicKeyCredentialCreationOptions` (challenge por
    CSPRNG **no servidor**); o front chama **`navigator.credentials.create()`** e devolve o
    attestation ao servidor para verificação. `challenge`/`user.id` chegam como `ArrayBuffer`
    (base64url→bytes), nunca inventados no cliente.
  - Autenticação: `navigator.credentials.get()` com as options do servidor; a asserção volta
    para verificação **server-side**. Faça **feature-detect** (`window.PublicKeyCredential`,
    `isUserVerifyingPlatformAuthenticatorAvailable`) e ofereça fallback quando indisponível.
  - `rp.id` casa com o domínio de `auth.<domain>`; a UI explica "use a biometria/PIN deste
    dispositivo". Passkey já é "2 fatores num" (dispositivo + biometria).
- **Senha por padrão, opcional por escolha:** o formulário de cadastro pede senha (padrão
  cultural; força medida no cliente **só como dica de UX**, verificação real — argon2id +
  HIBP — **no servidor**), mas o **seletor de modos de autenticação permite marcá-la como
  opcional** e viver de passkey/OTP/app.
- **Senha + Email OTP já é 2FA — a UI NUNCA bloqueia o login por falta de fator forte:** a
  conta nasce em 2FA baseline (senha + código no email verificado); a tela **libera o acesso
  baseline** e apenas **sugere** (card dispensável, §nudge) enrolar um fator forte (app/passkey)
  e um 2º email. O fator forte é pedido **just-in-time** — quando o usuário faz algo sensível
  (a tela dispara o **step-up**) ou quando o servidor sinaliza risco (§4) — **nunca** como muro
  pré-login. Tratar quem tem senha+OTP como "sem 2FA" e travar a entrada é o círculo infinito
  **VETADO**.
- **Email OTP / SMS** entram como campos de código (6 dígitos, `inputmode="numeric"`,
  `autocomplete="one-time-code"`, colar/auto-preenchimento), com reenvio em **backoff** e
  feedback de rate-limit — sem revelar se o identificador existe.

### Seletor de método (o usuário escolhe qual fator usar)

Quando há **vários fatores enrolados** (passkey + app + telefone + email), a tela de login
**lista todos os métodos disponíveis e o usuário escolhe** qual usar naquele acesso —
nunca força um único caminho. Ordena por força/conveniência (passkey primeiro), rotula
cada um ("Passkey neste dispositivo", "App autenticador", "Código por email …@…"), e
mostra fallback. A **lista de métodos disponíveis vem do servidor** para aquele usuário
(a UI não decide o que ele tem).

## 4. Fluxos de UI

**Onboarding (cadastro):** a tela conduz **email → verifica (código) → cria senha** (ou já
passkey/app) → **pronto: 2FA baseline (senha + Email OTP) e acesso liberado**. Cada passo é
uma tela com estado de loading/erro/vazio desenhado. **Depois** de entrar, a UI **sugere**
(cards dispensáveis, não bloqueiam): **2º email de backup** (nudge, §nudge) e **fator forte**
(app/passkey). "Pular por agora" é **permitido** para o fator forte — ele é pedido
*just-in-time* na 1ª ação sensível (step-up), nunca antes de entrar.

**Login:** (1) sem app de 2FA ativo → **OTP por email** (é o 2º fator baseline, não "sem 2FA");
(2) com app → **pergunta app ou email**; (3) com vários fatores → **seletor de método** (§3).

**Step-up e risco (a UI reflete, o servidor decide):** ação sensível → a tela pede o **fator
forte fresco** (enrola na hora se não tiver). Quando o servidor sinaliza **risco** (device/IP
novo, geovelocidade), a UI **pede um fator a mais** (2FA→3FA: senha → email → app/chave) —
conforme o servidor mandar. A UI **não decide** o risco nem revela o motivo: erro de auth é
sempre a **mensagem genérica** ("credenciais inválidas") com **tempo uniforme** — inclusive
quando o servidor aplica negação deceptiva (§backend); a tela nunca vaza "senha certa, mas…".

**Gestão de fator — invariante de UI:**
> **Para mutar o fator X, a tela pede um fator Y ≠ X, no maior AAL disponível.**
- Desativar/trocar **app** → a UI verifica por **email** (ou outro ≠ app).
- Adicionar/trocar **email** (inclui o secundário do nudge) → a UI exige o **app**/passkey.
- Add/remover **passkey ou telefone** → mesmo princípio; a UI **lista qual fator usar**.
- Toda mudança **avisa o usuário que todos os canais verificados serão notificados**;
  remover o **último fator forte** vira **ação com atraso cancelável** (a UI mostra a janela
  para abortar). **A UI só orquestra o pedido — quem exige e valida o fator é o servidor.**

**Recuperação:** múltiplos caminhos na tela (outro email, códigos de backup offline,
telefone). A UI **nunca** oferece reset que pule o 2º fator — recuperação é **≥ força do
login** (2 fatores ou processo com atraso + revisão), com feedback de rate-limit.

**Rampa de saída de estado travado (anti-deadlock) — a tela oferece a saída, não só a exigência:**
> Com o 2FA baseline (senha + Email OTP) resolvido por desenho (§3), **não existe tela de
> "falta 2FA" barrando o baseline**. Esta regra fica para **qualquer outra exigência** que a UI
> imponha ("verifique seu email", "aprovação pendente", "enrole um fator forte para esta ação
> sensível"): a tela **conduz à rampa**, não só informa o bloqueio — o caminho de saída entra
> pelo **fallback always-on** (código por email no endereço que a pessoa já usa → sessão →
> resolve ali). O gate real segue server-side; a UI constrói o degrau.
- **VETADO como "saída":** botão/link para uma página que **exige sessão** (quem está travado
  não tem sessão — o link "não funciona se já não houver sessão" é o próprio bug); texto do
  tipo *"peça a quem administra sua organização"* para algo que **só o dono faz** (ninguém
  enrola o autenticador de outra pessoa). Saída que exige o que falta **não é saída**.
- A tela **nomeia** o caminho que existe (não deixa o Email OTP invisível quando ele é
  justamente a porta). Se a política de entrada varia por método (ex.: senha exige TOTP, mas
  magic link/OTP não), a UI **diz** qual porta está aberta — silêncio aqui vira conta presa.

## 5. Autorização no cliente — UX, nunca controle

- **`if (user.can('invoice:approve'))` no React é para PINTAR a tela** (esconder botão,
  desabilitar link) — **não** é controle de acesso. Toda ação sensível é **re-checada no
  servidor** (route handler/server action/API), que decide por **deny-by-default**.
- **`role`/`tenant_id`/`user_id` nunca vêm de prop, query, `localStorage` ou do JWT
  decodificado no cliente para autorizar** — a decisão real usa o token verificado
  server-side. O front pode **ler** claims só para UX (ex.: mostrar o nome do tenant).
- **Multi-tenant na UI:** troca de tenant é troca de **contexto de sessão** validada no
  servidor; a lista de permissões **não** viaja no token (token fino) — a UI consulta o que
  pode mostrar e **assume que pode estar stale** (o servidor é a verdade no submit).
- **Esconder ≠ proteger:** dado que o usuário não pode ver **não é buscado/enviado** ao
  cliente — nunca "vem no JSON e some no CSS". O que chega ao browser, o usuário vê.

## 6. Sessão, multi-dispositivo e logout — no cliente

- **Token em cookie `HttpOnly` + `Secure` + `SameSite`** (setado pelo servidor no
  callback). **JAMAIS** em `localStorage`/`sessionStorage`/memória global do JS — XSS lê
  tudo lá. O front **não manuseia** o access/refresh token; ele viaja no cookie.
- **Sessão longa por padrão (fim do "15 min e é chutado"):** o access token é curto mas o
  **refresh é silencioso** (server-side, via cookie) — para o usuário a sessão **persiste
  7 dias**; no login a UI **pergunta "confiar neste dispositivo?"** → se sim, **90 dias**.
  Ops sensíveis ainda disparam **step-up fresco** (§ step-up), sem enfraquecer a sessão.
- **View de dispositivos/sessões (tela de conta):** lista os dispositivos ativos com
  **rótulo amigável** ("Chrome no Windows"), IP/geo aproximada e último uso; permite
  **remover um** (revoga aquela sessão) e **"sair de todos os dispositivos"**. Cada linha é
  um pedido ao servidor — a UI reflete o resultado, não "apaga localmente".
- **Histórico de acessos + "não fui eu":** a tela mostra os **logins recentes** (device/IP/geo/
  horário, e os **marcados suspeitos** pelo risk engine do servidor) e um botão **"não fui eu"**
  que **revoga a sessão** e **puxa o reforço** (enrolar fator forte, trocar senha). O front
  **exibe** o veredito de risco do servidor; **não o calcula**.
- **Botão "Sair" bem visível → dispara o kill IRREVERSÍVEL server-side:** ao clicar, o
  front **chama o endpoint de revoke** (`POST /logout`, com CSRF token) e **só então**
  limpa o estado local e redireciona. **O kill real é server-side** — revoga o refresh
  token e a **família**, apaga o registro de sessão, joga o `jti` na denylist até expirar,
  desassocia o push token do device. **NUNCA confie no `document.cookie = ''`/limpar
  storage como logout:** apagar cookie no cliente não invalida a sessão no servidor; se a
  chamada de revoke falhar, a UI trata como erro (não "deslogou") e não finge sucesso.
- **Step-up UX para ops sensíveis** (trocar fator, billing, admin, cross-tenant): antes de
  submeter, a UI **reautentica em AAL alto** (passkey/`navigator.credentials.get()` ou
  push) — mas quem **exige e verifica** o step-up é o servidor; a tela não "libera" nada.

## 7. Enforcement é server-side — o cliente é sempre UX (lembrete que não se dilui)

Toda checagem no navegador (esconder botão, bloquear rota no client router, validar
formulário, `can()`/`isAdmin`) existe para **experiência**, não para segurança. **A
decisão de autenticação e autorização, a validação de token, o rate-limit, o kill de
sessão e a verificação de fator acontecem no servidor** (`schematize-go` / o serviço de
auth). Um atacante controla o cliente por completo: pode pular o React router, forjar
props, editar o bundle. Portanto **nenhum piso de segurança é satisfeito no front** — o
front **conduz o fluxo**; o servidor **decide e impõe**.

## 8. Rotina de testes (front) — detalhe na schematize-pentest

No pipeline de front, além do backend adversarial:
- **e2e (Playwright)** dos fluxos: onboarding completo (email→verifica→1º→2º fator),
  login com seletor de método, passkey (WebAuthn virtual authenticator), nudge de email
  secundário (detecção de provedor + tooltip acessível), view de dispositivos (remover um /
  sair de todos), **logout que de fato invalida** (após "Sair", reusar o cookie/rota
  protegida = 401, não volta a sessão).
- **a11y (axe)** em cada tela do fluxo (foco gerenciado, tooltip por teclado, `aria-*`).
- **Anti-vazamento no bundle:** gate que falha se aparecer token em `localStorage`,
  segredo em `NEXT_PUBLIC_*`/`VITE_*`, ou decisão de authz feita só no cliente.

## Checklist (entra na Definition of Done quando o projeto tem auth — recorte front)
- [ ] **Front de auth é app SEPARADO** (`auth.<domain>`, `<projeto>_authfront`) — nunca embutido no site principal.
- [ ] Cliente delega por **OIDC/OAuth2.1 + PKCE** (redirect a `auth.<domain>`; troca de code no servidor; nada de `client_secret` no bundle).
- [ ] **Onboarding conduzido** (email → verifica → senha → **acesso baseline com 2FA senha+Email OTP**); fator forte é **nudge + step-up just-in-time**, **NUNCA muro pré-login**; UI reflete escalonamento por risco (2FA→3FA) e mostra erro genérico (sem vazar negação deceptiva).
- [ ] **Seletor de método** lista os fatores enrolados e o usuário escolhe; **passkey/WebAuthn** via `navigator.credentials` com feature-detect e fallback.
- [ ] **Nudge de email secundário** com **detecção de provedor** (recomenda outro) + **"i" tooltip acessível** no hover/foco.
- [ ] **View de dispositivos** (remover um / "sair de todos"); **sessão 7d/90d** ("confiar neste dispositivo?"); step-up UX em ops sensível.
- [ ] **Token em cookie `HttpOnly`+`Secure`+`SameSite`**, NUNCA em `localStorage`; front não manuseia token.
- [ ] **Botão "Sair" → revoke server-side** (kill irreversível); a UI não finge logout apagando cookie/storage.
- [ ] **Nenhuma decisão de authz no cliente** (`can()`/`isAdmin` só pinta a UI); enforcement e validação **server-side** (§7). Dado oculto não é enviado.
- [ ] e2e/a11y dos fluxos + gate anti-vazamento (token em storage, segredo em `NEXT_PUBLIC_`, authz no cliente).
