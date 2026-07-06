# Operação e Deploy (frontend)

> Parte da skill **schematize-web**. O equivalente front do `operacao.md` do
> `schematize-go`: como o site vai pro ar e se mantém — alvos de deploy, cache de
> CDN, revalidação, env/segredos por ambiente, feature flags, rollback. Liga com
> `seguranca.md` (headers/segredos), `performance.md` (cache/CWV) e `qualidade.md`
> (DoD). O **fluxo de ambientes e o "nada direto no servidor/site"** (promoção
> dev→local→github→hml/preview→prd, deploy só pelo pipeline) são canônicos em
> `references/ops.md` — este arquivo detalha o **como** do deploy que aquele fluxo usa.

## Índice
- 54. Alvos de deploy
- 55. Cache e CDN
- 56. Config e segredos por ambiente
- 57. Feature flags e rollout
- 58. Rollback e runbook

---

## 54. Alvos de deploy

**MUST**
- **Alvo definido por natureza do site** e registrado em ADR:
  - **Estático (SSG)** — Astro/Next export em CDN/host estático: o mais rápido e
    barato; ideal pra content-driven.
  - **SSR/edge/serverless** — Next app dinâmico (Vercel ou equivalente): quando há
    personalização/auth/dado por request.
- **Build reprodutível:** lockfile commitado, versão de Node/ferramenta fixada
  (`.nvmrc`/`engines`/`rust-toolchain` no que aplica), build sem acesso a segredo
  de runtime que vaze pro artefato (§43.1).
- **Preview deploy por PR** (ambiente efêmero) pra revisar visual, a11y e CWV
  antes do merge — liga com regressão visual (§48.5).

**SHOULD**
- Imutabilidade de artefato: o mesmo build promovido entre ambientes (não
  rebuildar por ambiente); diferença é só config (§56).

---

## 55. Cache e CDN

**MUST**
- **Cache headers explícitos por tipo de recurso:**
  - **Assets com hash** (`/_next/static/...`, bundles versionados): `Cache-Control:
    public, max-age=31536000, immutable`.
  - **HTML/documento dinâmico:** sem cache compartilhado de conteúdo por-usuário;
    use `private, no-store` quando depende de sessão. Conteúdo público:
    `s-maxage` + `stale-while-revalidate` no CDN.
- **Revalidação direcionada (ISR):** páginas estáticas com dado que muda revalidam
  por tempo e/ou por **tag/caminho** no deploy/mutação (§50/§51) — não purgar o
  CDN inteiro a cada escrita.
- **Nunca cachear resposta autenticada em cache público** (vazamento cross-usuário) —
  `Vary`/`private`/`no-store` corretos.

**SHOULD**
- Purga de CDN automatizada e registrada no deploy; invalidação por tag quando o
  CDN suportar.

---

## 56. Config e segredos por ambiente

**MUST**
- **Config por ambiente** (dev/preview/prod) vem de variável de ambiente, **não**
  hardcoded e **não** commitada. `.env.example` sem valores; `.env` real fora do git.
- **Segredo só server-side** (§43.1): nada de segredo em var pública
  (`NEXT_PUBLIC_*`/`VITE_*`/`PUBLIC_*`). URL/ids públicos podem; chaves, não.
- **Paridade dev/prod:** mesma forma de config em todos os ambientes; diferença é
  valor, não estrutura. Secret manager do host pra prod; secret scan no CI.

**VETADO**
- Segredo no artefato de build (estático expõe tudo que entra no bundle).
- "Var pública só nesse ambiente" pra segredo — público é público em todo lugar.

---

## 57. Feature flags e rollout

**MUST**
- **Mudança arriscada atrás de flag** (com default seguro = desligado). Avaliação
  da flag no **servidor** quando ela controla acesso/dado (§43.6) — não só no
  cliente, que é burlável.
- **Flag tem dono e data de retirada** registrados (ADR/TASK). Flag morta vira
  dívida e ruído — remover faz parte da entrega.

**SHOULD**
- Rollout gradual (canário/percentual) pra mudança de risco; métrica de erro e
  CWV (§49) observada durante o rollout, com gatilho de reversão.

---

## 58. Rollback e runbook

**MUST**
- **Rollback em um passo:** promover o deploy anterior (imutável) reverte sem
  rebuild. Todo deploy é reversível; se não é, não vai.
- **Runbook do site** (`assets/RUNBOOK.md`) atualizado: como deployar, como
  reverter, onde ficam logs/erros (§49), o que monitorar (CWV de campo, taxa de
  erro), e o passo a passo do incidente comum (build quebrado, CDN servindo
  versão velha, pico de erro pós-deploy).
- **Pós-deploy prova conteúdo + CWV** (smoke §48.6): deploy "verde" que serve
  página quebrada ou lenta dispara reversão.

**SHOULD**
- Health/heartbeat público mínimo e alerta de Web Vitals de campo regredindo por
  release (atributo de versão na métrica — §49.2).

> Regra de bolso: **artefato imutável, config por ambiente, deploy reversível em
> um passo.** Se reverter exige rebuild ou caça a segredo, o pipeline está errado —
> conserta o pipeline, não o incidente no susto.
