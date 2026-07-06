---
description: schematize-web — verifica o fluxo de ambientes/preview, o deploy só pelo pipeline (nada direto no site/servidor) e, em multi-app, o build paralelo (nproc) e a independência
argument-hint: "[audit | flow | pipeline]"
---

Governe ambientes e deploy do frontend pelo **pipeline de CI/CD** (`references/ops.md`). Plan-first: **audita, mostra o plano, pede aprovação, então executa** — e **nada toca o site no ar fora do pipeline**.

## 1. Fluxo de ambientes (verifique primeiro)
Confirme que o processo força **dev local → teste local → GitHub → hml/preview → prd** e que **nada vai direto pra hml/preview ou prd**:
- Deploy só aceita **artefato com proveniência git** (commit SHA); build sem origem no git é recusado.
- **Artefato imutável:** o mesmo build é promovido entre ambientes (não rebuilda por ambiente; diferença é só config). Assets versionados por hash, servidos `immutable`.
- **Preview por PR** ligado (ambiente efêmero) — revisa visual/a11y/CWV antes do merge (§54, §48.5).
- **VETADO editar direto no site/servidor deployado.** Achou hotpatch no build publicado / asset trocado à mão no CDN/host → trate como **incidente** (archive, §28), não como fluxo.

## 2. O pipeline é a interface única de deploy (100%)
Verifique que build/publicação/promoção/rollback/config passam **só pelo pipeline**:
- **Proibido** deploy manual ad-hoc (`scp`/`rsync`/upload do build, "arrastar `dist/` pro painel", asset solto no CDN, deploy da máquina de alguém por fora). Operação sem etapa no pipeline é o achado: **adiciona a etapa** — não faz por fora.
- **Promoção sem depender da IA:** o próprio usuário promove hml→prd e reverte em **um passo** (botão/comando do pipeline). Rollback = promover o build anterior (imutável), nunca editar o site no ar (§58).
- **Config/segredo por ambiente** entram pelo pipeline/secret manager; **nada de segredo no artefato de build** (§43.1, §56).

## 3. Multi-app: build paralelo (= nproc) e independência
Só se aplica quando o projeto tem **múltiplos apps/pacotes/serviços de front** (monorepo com vários sites, app + BFF de front + design system publicável). Num site único é **N/A**.
- Build/subida roda **em paralelo**, grau = **`nproc`** (default; `--jobs N`/`OPS_JOBS` sobrepõe). Serialização só onde há dependência **real e declarada** (ex.: design system antes do app que o consome), mínima e explícita.
- **Independência é invariante.** Rode o build/preview **em paralelo de propósito**. Se **qualquer** erro só acontece em paralelo (porta/lock/arquivo disputado, app que não sobe sem outro): **PARE a feature** — é defeito de independência. O pipeline **expõe** a colisão; **proibido serializar pra mascarar**. Corrija (cada app sobe sozinho), só então o paralelo volta a `nproc`.

## 4. Saída
Grave o plano/relatório em `<projeto>_archive/` (§28): estado do fluxo de ambientes, cobertura do pipeline (o que ainda é manual), e — em multi-app — tempo de build, grau de paralelismo e qualquer colisão de independência (com a correção priorizada). Confirme ao usuário: fluxo ok? deploy/rollback só pelo pipeline (nada direto no site)? promoção operável sem a IA? multi-app com build paralelo em `nproc` e independência provada?
