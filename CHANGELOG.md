# Changelog — schematize-web

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [1.15.0] — 2026-08-21

### Adicionado
- **`observabilidade.md` §49.4 — a spec de consentimento**, que a `schematize-institutional` delegava a esta skill e não existia (o piso 2 dela era **inexequível por construção**). Dez pontos verificáveis: **nada não essencial antes da escolha** (*banner que aparece enquanto o pixel já disparou é teatro de conformidade*), aceitar e recusar com o **mesmo peso**, categorias (essencial é o que **quebra o site**, não o que o time gostaria), **registro auditável** (a LGPD exige **demonstrar** o consentimento — guarde o registro, não só o cookie), revogação que **apaga**, sem dark pattern, **categorias iguais às da política de cookies**, server-side obedecendo também, e o teste dos dois caminhos **provando na aba de rede**.

## [1.14.0] — 2026-08-21
Saneamento do catálogo conforme a vistoria de 2026-08-21.

### Corrigido
- **`assets/lint/eslint.config.mjs`** substitui o antigo `eslint.frontend.cjs`: flat config de verdade, com `eslint-plugin-react` **declarado** e `parserOptions.projectService`. Verificado rodando: `npx eslint src` reprova um `dangerouslySetInnerHTML` plantado (exit 1) — antes, a config sequer carregava.
- **`scripts/check-diff.sh`**: `scan()` passou a distinguir exit ≥ 2 (erro da ferramenta) de "não achou", e o `danger_check()` **bloqueia sem sanitizador declarado** em vez de avisar — mais o guard de `grep -P` para não falhar silenciosamente onde o `perl` não está disponível.

### Mudado
- O anexo volátil (`references/stack-versoes.md`) é a **fonte única** dos thresholds de Core Web Vitals do catálogo — a `schematize-seo` passou a apontar para cá em vez de manter os números.

## [1.13.0] — 2026-08-20
Propagação do piso "efeito externo NUNCA sai de não-produção" no recorte de frontend — o preview deploy é onde escapa e-mail real.

### Adicionado
- **Piso inegociável na `SKILL.md`: "Efeito externo NUNCA sai de não-produção — e `preview` NÃO é produção"** — server action / route handler / BFF que dispara e-mail (contato, newsletter, convite, reset de senha, magic link, notificação), SMS, push, webhook ou cobrança segue o mesmo guard da normativa (`schematize-engineering` → `references/efeitos-externos.md`): provider resolvido no servidor por ambiente, **default = SINK** fora de `prd`, **guard deny-by-default DENTRO do provider**, **cap por execução** e **fail-closed**.
- **`references/seguranca.md` §43.8 (corpo da regra):** o ponto não é a chave (§43.1 já a veta no bundle) — é o **ENVIO**. Tabela de escopo Production/Preview/Development/indeterminado, **`VERCEL_ENV`** (Netlify `CONTEXT`, CF Pages pelo branch) como discriminador correto e **`NODE_ENV` sozinho VETADO** (é `production` também no build de preview — o erro clássico); chave de produção do provedor **só no escopo Production**; endereço sintético só no domínio de teste em rota nula.
- **Rate-limit e anti-abuso no endpoint público de envio (§43.8):** form de contato/newsletter aberto na internet é **bomba de e-mail de graça** e relay de spam — rate-limit por IP + por destinatário, cap global por janela, anti-bot (Turnstile/honeypot) verificado no servidor, **double opt-in** em newsletter e **destinatário FIXO no servidor** (`to`/`cc`/`bcc` do corpo da requisição = relay aberto; campo do usuário só como corpo escapado, nunca header — `\r\n` é header injection).
- **`references/anti-padroes.md` §37 item 55:** "server action / route handler / BFF mandando e-mail REAL a partir de preview, branch deploy ou dev", com o caminho certo em 4 pontos.
- **`assets/CLAUDE.md` piso 20:** a mesma regra pinada no contexto sempre-on do repositório.
- **`references/operacao-deploy.md` §56:** env var **por escopo** no provedor — credencial de envio de produção só em Production; **preview/branch deploy carregando chave de envio de prd é incidente** (rollback de env + rotação), não conveniência.

### Mudado
- **`description` do frontmatter** passa a listar o piso ("efeito externo nunca sai de não-produção — preview é sink") e a linha do mapa de references de `seguranca.md` cita o envio/efeito externo.
- **Regra de bolso da §37** amplia a lista de gatilhos com "dispara e-mail de verdade a partir de um preview/dev".

## [1.12.1] — 2026-08-18
Correção da contradição do muro pré-login de IAM (alinha ao `iam.md` da schematize-engineering).
### Mudado
- **/web-iam**: removido o "2º fator forte obrigatório antes do acesso pleno" e o "força 2º fator no 1º login" — o muro pré-login / deadlock de bootstrap VETADO pela norma. Agora senha+Email OTP = 2FA baseline; fator forte é nudge + step-up just-in-time.
`schematize-go`: o que for servidor/API/dados delega ao schematize-go.

## [1.12.0] — 2026-08-15
Reflexo no front da correção de IAM — 2FA baseline sem muro pré-login + UX de risco/step-up.

### Mudado (correção de piso)
- **`references/iam.md` §3/§4 + checklist; `anti-padroes.md` #49:** a UI **nunca bloqueia o login por falta de fator forte** — senha + Email OTP é 2FA baseline; o onboarding libera o acesso e **sugere** (cards dispensáveis) reforçar. Fator forte é **step-up just-in-time**, "pular por agora" é permitido.

### Adicionado
- **UX de risco/step-up** (`references/iam.md` §4): a UI reflete o escalonamento por risco (2FA→3FA) que o servidor manda e mostra **erro genérico com tempo uniforme** (nunca vaza a negação deceptiva do backend); **nudge de fator forte** irmão do nudge de email secundário; **histórico de acessos + "não fui eu"** na view de sessões (exibe o veredito de risco do servidor, não o calcula).

## [1.11.0] — 2026-08-15
Lições de um incidente real de front — auth/onboarding travado, troca de contexto, testes que não rodam.

### Adicionado
- **Rampa de saída de estado travado (anti-deadlock)** (`references/iam.md` §4): a tela de "falta 2FA" **conduz à rampa** (código por email → sessão de baixo AAL → enrola o fator forte ali mesmo), não só informa o bloqueio; **VETADO como "saída"** link para página que exige sessão (quem está travado não tem) ou texto "peça a quem administra sua org" para algo que só o dono faz; a UI **nomeia** a porta aberta quando a política de entrada varia por método.
- **A resposta certa vence, não a que chega por último** (`references/dados-estado.md` §50): troca de contexto rápida (org/aba/busca) não deixa resposta **obsoleta** sobrescrever o estado atual — cancelar (`AbortController`) **ou** versionar por chave (descartar resposta cuja chave ≠ atual); `AbortController` é um meio, cache keyed (TanStack/SWR) resolve por design. Sintoma: "pintar a org anterior".
- **Contexto explícito para escrita + ID não é rótulo** (`references/ui-padroes.md` Piso + checklist): ação de escrita **abre no contexto ativo** (ou força escolha) e mostra onde grava, nunca "primeiro de N"; ULID/UUID é **chave, não rótulo** — mostra o nome, ID só secundário.
- **Runner tem que coletar o teste + red-first** (`references/testes.md` §48.6): o `include`/glob do vitest cobre `.test.tsx` (senão o teste **não roda e não avisa** — falso-verde silencioso); teste novo confirmado **falhando** antes do verde.

## [1.10.0] — 2026-07-11
Padrões de UI que a geração padrão erra — app-shell/menu lateral, largura fluida, gráficos, date-picker/modal Material, mobile utilizável.

### Adicionado
- **`references/ui-padroes.md`** — a camada de **padrões de aplicação** que o front gerado quase sempre entrega mal (o "sofrível" padrão): **(1) app shell** — header + **menu lateral** (rail colapsável, rota ativa, teclado; **drawer off-canvas no mobile**) + conteúdo fluido; **(2) largura dinâmica** — `clamp`/`minmax`/`auto-fit`/`%`, texto ≤75ch, container queries, **zero scroll-x no body** (nada de largura fixa quebrada); **(3) gráficos incentivados** — todo objeto/entidade com dado agregável/série/proporção merece visualização (lib leve tipo Recharts/ECharts, **lazy**, tipo certo pro dado, tokens/dark, **acessível** com fallback tabela + 3 estados; cross-link à skill `dataviz`); **(4) date-picker e (5) modal no padrão Material/Google por primitivo acessível** (react-day-picker/MUI X; Radix Dialog/`<dialog>`) — nunca à mão: modal com scrim/focus-trap/`Esc`/foco-de-volta/**full-screen no mobile**, picker com locale/timezone/teclado+calendário; **(6) responsividade + mobile utilizável como gate** — ~360px, alvos ≥44px, sem affordance só-hover, tabela reflui (cards/scroll), teclado on-screen não cobre input, safe-areas. Inclui **piso** e **checklist de reprovação**.
- **Piso 19** no `CLAUDE.md`; bullet + linha na tabela de references do `SKILL.md`; anti-padrões **50–54** (app sem shell/sidebar; largura fixa/scroll-x; dado sem gráfico; date-picker/modal quebrado à mão; front não testado no mobile); `/web-review` ganha as checagens de UI/mobile.

## [1.9.0] — 2026-07-11
IAM por desenho no cliente — front de auth próprio, fluxos/passkey/nudge/dispositivos, logout irreversível.

### Adicionado
- **`references/iam.md`** — recorte **frontend/cliente** do piso de IAM da casa. **Front de auth é app SEPARADO** (`<projeto>_authfront` em `auth.<domain>`; **VETADO** embutir login/cadastro/2FA no bundle do site principal); cliente **delega por OIDC/OAuth2.1 + PKCE** (`code_verifier` por CSPRNG, **troca de code por token no servidor**, `client_secret` nunca no bundle). **Onboarding conduzido** (email→verifica→1º fator→**2º fator forte obrigatório**→acesso); **seletor de método** (lista os fatores enrolados, o usuário escolhe); **passkey/WebAuthn no browser** via `navigator.credentials` (feature-detect + fallback). **Nudge de email secundário** com **detecção de provedor** (gmail/hotmail-outlook/yahoo/próprio) recomendando outro provedor + **"i" tooltip acessível** no hover/foco. **View de dispositivos** (remover um / "sair de todos"); **sessão 7d/90d** ("confiar neste dispositivo?"); step-up UX em ops sensível. **Token só em cookie `HttpOnly`+`Secure`+`SameSite`, nunca em `localStorage`** (o front não manuseia token). **Botão "Sair" → revoke server-side irreversível** (não basta apagar cookie/storage). **Nenhuma decisão de authz no cliente** (`can()`/`isAdmin` só pinta a UI; dado oculto não é enviado) — **enforcement, validação de token e kill de sessão são server-side** (§7, lembrete que não se dilui). Backend/serviço de auth/motor ReBAC/migração ficam no `schematize-engineering`/`schematize-go`.
- **Comando `/web-iam`** (plan-first): força/audita/scaffolda o IAM do lado do cliente (o `authfront` + fluxos de login/2FA/passkey, nudge, view de dispositivos, logout irreversível).
- **Piso 18** no `CLAUDE.md` (front de auth próprio, ID≠email, ≥2 fatores, nudge de email secundário, view de dispositivos, sessão 7d/90d, logout irreversível, enforcement server-side); bullet nos pisos + linha na tabela de references + `/web-iam` na tabela de comandos do `SKILL.md`; anti-padrões **45–49** (auth embutido no site principal; token em `localStorage`; authz decidida no cliente; logout que só apaga cookie; email como ID / 1 fator); `/web-load` carrega `iam.md`; `/web-help` lista `/web-iam`.

## [1.8.0] — 2026-07-11
Limite de arquivo em camadas — teto de 750 (≤500 úteis + ~250 comentário) + flag em >300 úteis.

### Alterado
- **`references/padroes-codigo.md` §1/§2:** o limite rígido de **300 linhas/arquivo** vira regra **em camadas**. **Teto DURO: 750 linhas** (das quais **~250 reservadas a comentário/doc** e **até ~500 de código útil**) — acima bloqueia. **FLAG (não bloqueia, mas SEMPRE sinaliza) em > 300 linhas de código útil:** indício de que o componente/hook/função está **muito extenso** / **precisa de mais abstração** — registra como dívida e **revê quando as prioridades forem resolvidas**. **Observabilidade de front tem folga natural (~400 úteis).** Componente/função com >300 úteis dispara o mesmo flag; "uma função/componente por arquivo" mantida (quebrar por coesão em micro-componentes/hooks).
- **`scripts/check-diff.sh`:** o gate de tamanho passa a contar **código útil** (exclui comentário/branco): `total > 750` **bloqueia**, `útil > 500` **bloqueia**, `útil > 300` (ou `> 400` em arquivo de observabilidade) **flagueia** (`warn`, não trava).
- Propagado no piso do `CLAUDE.md`, `SKILL.md`, `references/qualidade.md` (§6/DoD), `references/arquitetura.md` (§41.1), `site/llms.txt` e comandos `/web-load` `/web-help` `/web-review`.

## [1.7.0] — 2026-07-06
Refino visual — ícones (nunca emoji) + as alavancas táticas que fazem um front parecer desenhado.

### Adicionado
- **`references/design-refino.md`**: a camada tática que faltava (coesão por tokens evita o site *quebrado*, mas não o faz parecer *desenhado*). **Regra zero — ícones, nunca emoji** na estrutura do site (a menos que o usuário peça): um icon set (Lucide/Phosphor/Heroicons/Radix), SVG `currentColor`, tamanho por token — emoji renderiza diferente por SO, não herda cor/peso (quebra tema/dark) e destoa da marca. **13 alavancas** com números-default: espaço generoso/assimétrico (entre seções ≫ dentro), hierarquia com salto grande + de-ênfase por cor, **um** acento em neutros com tint (off-black/off-white), elevação por hairline **ou** sombra em camadas (nunca borda grossa/sombra dura), linha ≤75ch, grade/alinhamento ótico, tipo com craft (line-height por tamanho, letter-spacing, tabular-nums), raio aninhado, 4 estados por interativo, imagens tratadas, empty/loading(skeleton)/erro desenhados. **Checklist de reprovação** ("tá feio, por quê?") pra rodar antes de dar o layout por pronto.
- Piso **17** no `CLAUDE.md` (ícones-não-emoji + refino não-opcional); bullet no SKILL.md + linha na tabela de references; anti-padrões **42–44** (emoji na estrutura; misturar icon sets; front "coeso" mas amador). Cross-link de `design-referencias.md`.

## [1.6.0] — 2026-07-06
Build/deploy destrutivo do zero (git+env) + isolamento por app (adaptado a frontend).

### Adicionado
- references/ops.md: fonte única de config/env; todo (re)deploy é build limpo do zero a partir do git+env (sem artefato/cache stale, sem editar o site publicado), preservando dados; isolamento por app (self-host: user Linux + systemd/container hardened; host gerenciado: sandbox imutável do provedor).
- Piso no CLAUDE.md; anti-padrões (deploy com build/cache stale; editar site publicado; config fora da fonte única); /web-ops estende as checagens.

## [1.5.0] — 2026-07-05
Fluxo de ambientes e deploy pelo pipeline (adaptado a frontend).

### Adicionado
- references/ops.md (frontend): fluxo dev→local→github→hml/preview→prd, nada direto no servidor/site (só via git→CI/deploy, artefato imutável); pipeline como interface única de deploy/rollback (promoção sem depender da IA); paralelo/independência quando o sistema tem múltiplos apps/serviços.
- Comando /web-ops; pisos no CLAUDE.md; anti-padrões (editar site deployado, subir direto pra prd, deploy manual fora do pipeline); qualidade.md com o fluxo; /web-load carrega ops.md.

## [1.4.0] — 2026-07-05
Todo MD gerado no archive, root limpo.

### Corrigido
- MAPA/índice saíam no root → agora `<projeto>_archive/index/` (padroes-codigo §4, MAPA.md, /web-index, build-index.mjs, CLAUDE.md, SKILL.md).

### Adicionado
- Layout canônico do archive (qualidade.md): todo MD gerado em `<projeto>_archive/<área>/`, NUNCA no root.

## [1.3.0] — 2026-07-03

### Alterado
- **Índice/MAPA exaustivo e como grafo** (§4 / §39 / `/web-index` / `MAPA.md` / `CLAUDE.md`): o índice passa a exigir **uma entrada por componente/hook/função/rota** de cada serviço/app (`nº entradas == nº unidades`). O `/web-index` **conta as declarações** e **reprova** se o índice tiver menos entradas, listando as ausentes pelo nome — chega de mapa magro (o caso "90 linhas pra 100+"). Removida a brecha do "relevante". O MAPA vira **grafo** (serviços + chamadas, Mermaid + adjacência), não lista.

## [1.2.0] — 2026-07-03

### Adicionado
- **Contenção no workspace** (§40.1 / anti-padrões §37 / `CLAUDE.md`): aplicação/repo novo nasce **dentro da pasta do projeto atual** (`./<projeto>_<contexto>/`). Veto a começar largando arquivos no root e depois **subir de diretório** (`cd ..`, `../`) pra criar repos irmãos fora, ou espalhar arquivos em `~`/`Documents`/`Downloads`/`/tmp`/Área de Trabalho. O agente **não sai da pasta do projeto** (ler ou escrever) sem o usuário pedir.

## [1.1.1] — 2026-06-27

### Adicionado
- Novo reference **`design-referencias.md`**: referências de design **além do apple.com** (Stripe, Linear, Vercel, Family, Refactoring UI…) e **método de coesão visual** (tokens + escalas + `DESIGN.md`).
- `/web-claude` passa a **mesclar** o `CLAUDE.md` em repo multi-linguagem (não sobrescreve blocos de outras skills).

## [1.1.0] — 2026-06-27

### Adicionado
- **Headers de segurança do site** (CSP imposta + CSP estrita em Report-Only, X-Content-Type-Options, Referrer-Policy, X-Frame-Options, Permissions-Policy, COOP, CORP, HSTS) — §43.3.
- **Observabilidade de front integrada ao LGTM+ da casa** (Grafana Faro + OpenTelemetry-JS → Alloy → Tempo/Loki/Prometheus/Mimir; W3C Trace Context ponta a ponta) — §49.5.
- **Convenção de nome de repositório** `<projeto>_<contexto>[_<lang>]` — §40.1.
- Comandos: **`/web-load`** (carrega à força o corpo normativo) e **`/web-claude`** (cria/atualiza o `CLAUDE.md` da raiz).

## [1.0.0] — 2026-06-20
Primeira release do **schematize-web** — padrões normativos de frontend da casa,
com foco em sites rápidos em SEO e velocidade.

### Adicionado
- Conhecimento normativo fatiado em `references/` (arquitetura/fronteira client-server,
  segurança, acessibilidade WCAG 2.2 AA, performance/Core Web Vitals, SEO + dados
  estruturados + i18n, qualidade/índice/DoD, testes, observabilidade, anti-padrões,
  stack/versões, contexto Claude Code).
- Comandos: `/web-help`, `/web-cc`, `/web-handoff`,
  `/web-qa` (a11y/CWV/e2e/visual), `/web-review`, `/web-index`.
- Scripts: `lib.sh`, `smoke-selfcheck.sh`, `check-diff.sh` (macaquices de frontend),
  `build-index.mjs` (índice de componentes/hooks), `gen-sitemap.mjs` (sitemap
  autogerado estático/dinâmico com hreflang), `archive-secret-scan.sh`, hooks de contexto.
- Assets: `CLAUDE.md`, templates (ADR/TASK/CHAT/PR/RUNBOOK/INDEX_GLOBAL/INDEX_COMPONENTS),
  `settings.claude.example.json`, CI (`ci/` com Lighthouse/axe/e2e/visual), lint
  (`lint/` eslint a11y+security+fronteiras, tsconfig strict), pre-commit (`hooks/`).
- Site `skills.schematize.me/web` (multi-idioma PT/EN/ES, AI-friendly) + instalador.

### Pisos inegociáveis cobertos
- Segredo nunca no cliente / `NEXT_PUBLIC_`; token em cookie HttpOnly, nunca localStorage;
  auth/authz decididas no servidor (§43).
- Sem `dangerouslySetInnerHTML` não sanitizado; CSP + headers (§43).
- Acessibilidade WCAG 2.2 nível AA como piso (§44).
- Core Web Vitals e budgets como contrato no CI (§45).
- SEO técnico + dados estruturados + sitemap autogerado + i18n com URL por idioma (§46/§47).
- Arquivos ≤300 linhas + doc-comment + índice como fonte da verdade (§6/§39).
- Testes "verde de verdade" (unit/componente/e2e/a11y/visual) com gate de a11y e CWV (§48).
- Archive obrigatório (§28); Q.A. plan-first (§48.7); handoff de contexto (§34.1).
- Stack só Next.js ou Astro; Node permitido só no frontend (§40).
