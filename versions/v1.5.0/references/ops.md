# Ambientes e deploy pelo pipeline — nada direto no servidor/site (control plane de front)

> Parte da skill **schematize-web**. Contraparte de frontend do `ops.md` do `schematize-engineering`, **adaptada ao front**: um site não sobe microserviços, mas o **fluxo de ambientes** e o **nada direto no servidor** valem **100%**. Dois invariantes desta reference, ambos **INEGOCIÁVEIS**: (1) nada chega a hml/prd sem passar pelo **fluxo de promoção** (dev local → teste local → GitHub → hml/preview → prd); (2) o **pipeline de deploy/CI é a interface única** — deploy, rollback e config passam pelo pipeline, nunca por deploy manual ad-hoc no site já publicado. Deploy/CDN/rollback: `operacao-deploy.md` (§54–§58). Fronteira e apps: `arquitetura.md` (§40). Observabilidade do release: `observabilidade.md` (§49). Archive/DoD: `qualidade.md` (§28, §35).

## 1. Ambientes e o fluxo de promoção (nada direto no servidor/site)

Ambientes isolados: **dev** (local) · **hml/preview** (homologação/staging, inclui o preview efêmero por PR) · **prd** (produção). O caminho de qualquer mudança é **fixo e sem atalho**:

```
desenvolvimento local  →  teste local (verde)  →  GitHub (merge)  →  hml/preview  →  prd
```

- **Nada pula etapa.** Nunca vai direto pra hml/preview ou prd. hml/preview só recebe o que está no GitHub e passou no teste local; prd só recebe o que foi homologado (revisado em preview: visual, a11y e CWV — §48.5).
- **VETADO editar direto no site/servidor deployado (hml/prd).** No frontend isso significa: **não mexer no build já publicado** — não editar HTML/JS/CSS servido pelo CDN/host, não hotpatch de arquivo no servidor, não trocar asset "na mão" no bucket/edge. O site deployado é **imutável por edição manual**; recebe apenas **artefato promovido do git** (mesmo build, **commit SHA rastreável**, §54). "Editei direto no prd pra resolver rápido" é o anti-padrão que esta reference existe pra matar (§37).
- **Hotfix segue o mesmo fluxo, acelerado:** branch → teste local → git → hml/preview → prd. Urgência **não** autoriza mão no site publicado.
- **Preview por PR é parte do fluxo**, não um extra: cada PR sobe um ambiente efêmero (§54) onde se revisa visual/a11y/CWV **antes** do merge. É o "hml por mudança".
- **Precauções concretas** (guarda, não fé):
  - Deploy só aceita **artefato com proveniência git** (commit SHA); build sem origem no git é recusado.
  - **Artefato imutável:** o mesmo build é promovido entre ambientes — não se rebuilda por ambiente; a diferença é só config (§54, §56).
  - Assets versionados por **hash** e servidos `immutable` (§55) — não há "arquivo pra editar" no ar.
  - Divergência entre o que está no ar e o git (alguém publicou à mão) é **incidente** (archive, §28), não "jeitinho".

## 2. O pipeline é a interface única de deploy (deploy/rollback/config)

**Toda** operação que muda o que está no ar — buildar, publicar, promover entre ambientes, reverter, aplicar config/segredo por ambiente, purgar/invalidar CDN — passa pelo **pipeline de CI/CD**. **Zero** deploy manual ad-hoc:

- **Proibido** `scp`/`rsync`/upload manual do build pro servidor/bucket, editar arquivo no host, "arrastar a pasta `dist/` pro painel", subir asset solto no CDN, rodar o deploy da máquina de alguém fora do pipeline. Se o pipeline **não** cobre aquela operação, **o gap é o achado: adiciona a etapa no pipeline** — não faz por fora. O que não passou pelo pipeline não é reproduzível nem rastreável.
- **Promoção sem depender da IA (requisito, não meta):** o pipeline é **autodescritivo e reproduzível** — o próprio usuário promove hml→prd e faz rollback **sozinho**, sem a IA no meio. Deploy, promoção e reversão são **um passo** operável por humano (botão/comando do pipeline), não uma sequência de comandos manuais que só a IA sabe.
- **Rollback é do pipeline, em um passo:** promover o deploy anterior (imutável) reverte sem rebuild (§58). Reverter **nunca** é editar o site no ar nem rebuildar no susto.
- **Config/segredo por ambiente** entram pelo pipeline/secret manager do host (§56), nunca hardcoded nem editados no servidor. Segredo **jamais** no artefato de build (§43.1).
- O pipeline **prova conteúdo + CWV pós-deploy** (smoke §48.6) e emite o sinal de release pra observabilidade (§49); cada promoção/rollback **gera archive** (§28).

## 3. Múltiplos apps/serviços: instalação paralela e independência

Num **site/app único** o paralelismo de subida é **N/A** — há um artefato só. Mas quando o projeto tem **múltiplos apps/pacotes/serviços de front** (monorepo com vários sites, app + BFF de front + design system publicável, várias landings), vale o mesmo piso de runtime do `schematize-engineering`:

- **Build/instalação/subida em paralelo**, grau = **número de cores** (`nproc`, default; configurável por `--jobs N`/`OPS_JOBS`). Não se builda um monorepo de 6 apps em série "um de cada vez".
- **Serialização só onde há dependência real e declarada** (ex.: o pacote de design system builda antes do app que o consome) — o **mínimo**, explícito no grafo de build, nunca "serializa tudo por via das dúvidas".
- **Independência é invariante.** Se a subida/preview **em paralelo falha** (porta/lock/arquivo disputado, um app que não sobe sem o outro, ordem implícita não declarada), isso **prova** que os apps **não são independentes** — e ferir isso é **defeito arquitetural**, não "conveniência de build". **Corrigir a independência é PRIORIDADE MÁXIMA:** o pipeline **expõe** a colisão (o que disputou o quê), **nunca serializa pra mascarar**. Cada app sobe sozinho; só então o paralelo volta a `nproc`.

## 4. Integração com o resto da casa

| Tema | Onde |
|---|---|
| Alvos de deploy, preview por PR, artefato imutável, cache/CDN, rollback, runbook | `references/operacao-deploy.md` (§54–§58) |
| Fronteira client/server, apps/pacotes, stack (Next/Astro) | `references/arquitetura.md` (§40) |
| Config/segredos por ambiente; segredo nunca no bundle | `references/seguranca.md` (§43.1) · `references/operacao-deploy.md` (§56) |
| Observabilidade de release (erro/CWV de campo por versão) | `references/observabilidade.md` (§49) |
| Archive de cada deploy/promoção; Definition of Done | `references/qualidade.md` (§28, §35) |
| Smoke pós-deploy (prova conteúdo + CWV) | `references/testes.md` (§48.6) |

Comando: **`/web-ops`** — verifica o fluxo de ambientes/preview, confirma que o deploy/rollback passa **só pelo pipeline** (nada direto no site) e, em projeto multi-app, checa build paralelo (`nproc`) e independência.

> Regra de bolso: **nada toca o site no ar fora do pipeline, e nada chega a hml/prd sem passar por git + teste local.** Artefato imutável, promoção em um passo (o usuário promove sem a IA), rollback pelo pipeline. Multi-app: build paralelo por padrão; se o paralelo quebra, o bug é de independência — e é a correção mais urgente que existe.
