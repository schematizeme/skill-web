#!/usr/bin/env bash
# check-diff.sh — gate determinístico de padrões de frontend (§6, §35, §37) sobre o diff.
# Uso: bash scripts/check-diff.sh [base-ref]   (default: origin/main)
# Sai 1 se achar qualquer violação de PISO; imprime achados com arquivo:linha.
#
# Cobre o que dá pra checar por regex/contagem. O julgamento fino (semântica de
# auth client vs server, sanitização real, fronteira RSC) fica pro /schematize-review
# com leitura humana/da IA. Falso-positivo se resolve com refator ou ADR — não
# afrouxando o gate.

set -uo pipefail
BASE="${1:-origin/main}"
FAIL=0
RED=$'\033[0;31m'; YLW=$'\033[0;33m'; GRN=$'\033[0;32m'; RST=$'\033[0m'

# Arquivos de código de frontend alterados (exclui testes, gerados, migrations).
mapfile -t FILES < <(git diff --name-only "$BASE"...HEAD 2>/dev/null \
  | grep -E '\.(ts|tsx|js|mjs|cjs|jsx|astro|vue|svelte)$' \
  | grep -vE '(_test\.|\.test\.|\.spec\.|/__tests__/|/generated/|\.gen\.|/mocks?/|\.d\.ts$|/node_modules/)' || true)

block() { echo "${RED}✗ BLOQUEIA${RST} $1"; FAIL=1; }
warn()  { echo "${YLW}⚠ ATENÇÃO${RST} $1"; }

echo "== schematize-web check-diff (base: $BASE) =="

# 1) §6 — tamanho de arquivo em camadas: teto DURO 750 (≤500 útil + ~250 comentário),
#    FLAG (não bloqueia) em >300 de código útil (~400 em observabilidade).
useful_lines() { # conta linhas de código útil: exclui branco e linha só-comentário (aprox multi-linguagem)
  grep -vcE '^[[:space:]]*($|//|#|///|/\*|\*/|\*[^/])' "$1" 2>/dev/null || echo 0
}
is_observ() { echo "$1" | grep -qiE '(observ|telemetr|tracing|/metrics?|metric|instrument|logg?(er|ing)|otel|prometheus|opentelemetry)'; }
for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  total=$(wc -l < "$f"); useful=$(useful_lines "$f")
  if (( total > 750 )); then
    block "$f: $total linhas (>750 teto duro; ~250 são p/ comentário, ~500 úteis) — quebre por coesão (§6)"
  elif (( useful > 500 )); then
    block "$f: $useful linhas de código útil (>500 teto duro) — quebre por coesão (§6)"
  else
    thr=300; ctx=""
    is_observ "$f" && { thr=400; ctx=" [observabilidade infla ~400]"; }
    (( useful > thr )) && warn "$f: $useful linhas de código útil (>$thr)$ctx — indício de componente/função muito extensa / falta de abstração; FLAG, registre como dívida p/ rever quando prioridades permitirem (§6)"
  fi
done

# 2) §37/§43/§44 — macaquices grep-áveis (padrão -> mensagem)
scan() { # scan "regex" "mensagem"
  local re="$1" msg="$2" hit
  for f in "${FILES[@]}"; do
    [[ -f "$f" ]] || continue
    hit=$(grep -nE "$re" "$f" 2>/dev/null || true)
    [[ -n "$hit" ]] && while IFS= read -r l; do block "$f:${l%%:*} — $msg"; done <<< "$hit"
  done
}

# --- Segredo no cliente (§43.1) ---
scan '(NEXT_PUBLIC_|VITE_|PUBLIC_|REACT_APP_)[A-Z0-9_]*(SECRET|PASSWORD|PRIVATE|SERVICE_ROLE)' \
  'segredo exposto via prefixo público (NEXT_PUBLIC_/VITE_/PUBLIC_/REACT_APP_) (§43.1/§37)'
scan '(NEXT_PUBLIC_|VITE_|PUBLIC_|REACT_APP_)[A-Z0-9_]*(API_KEY|APIKEY|ACCESS_KEY|AUTH_TOKEN)' \
  'chave/token exposto via prefixo público — passe por BFF/server (§43.1/§37)'

# --- Sessão em storage errado (§43.2) ---
scan '(localStorage|sessionStorage)\.(setItem|getItem)\(\s*[`"'\'']?(token|jwt|access[_-]?token|refresh|session|auth)' \
  'token/sessão em localStorage/sessionStorage — use cookie HttpOnly (§43.2/§37)'

# --- XSS (§43.4) ---
scan 'dangerouslySetInnerHTML' \
  'dangerouslySetInnerHTML — só com sanitizador allowlist; confirme em /schematize-review (§43.4/§37)'
scan 'v-html=' 'v-html (Vue) — equivale a innerHTML cru, sanitize (§43.4/§37)'
scan '\b(eval|Function)\s*\(|new\s+Function\s*\(' 'eval/new Function — proibido com input (§43.4/§37)'
scan '\.innerHTML\s*=' 'atribuição direta a innerHTML — use textContent/sanitize (§43.4/§37)'

# --- TS silenciado (§40/§37) ---
scan '@ts-ignore|@ts-nocheck|:\s*any\b|<any>|as\s+any\b' \
  'tipo silenciado (any/@ts-ignore/@ts-nocheck) — TS strict, tipa de verdade (§40/§37)'

# --- Erro engolido (§37) ---
scan 'catch\s*\([^)]*\)\s*\{\s*\}|\.catch\(\s*\(\s*\)\s*=>\s*\{?\s*\}?\s*\)' \
  'erro engolido (catch vazio) — trate ou propague (§37)'

# --- Lint de a11y/segurança desabilitado (§44/§43) ---
scan 'eslint-disable.*(jsx-a11y|security|no-danger)' \
  'desabilitando regra de a11y/segurança inline — VETADO (§44/§43/§37)'

# --- Acessibilidade quebrada (§44) ---
scan 'outline:\s*(none|0)\b|outline:\s*['\''"]none' \
  'outline:none remove foco visível — só com substituto equivalente (§44/§37)'
scan 'tabindex=["'\'']?[1-9]' 'tabindex positivo quebra ordem de foco — use 0/-1 (§44/§37)'
scan '<img(?![^>]*alt=)' 'img sem alt — toda imagem tem alt (vazio se decorativa) (§44/§37)'
scan 'user-scalable\s*=\s*no|maximum-scale\s*=\s*1' 'viewport bloqueia zoom — VETADO p/ a11y (§44/§37)'

# --- React/data fetching (§41/§42) ---
scan 'key=\{(index|i|idx)\}' 'key={index} em lista — use id estável (§41/§37)'
scan '@next/next/no-img-element' 'silenciando next/image — use o componente de imagem (§45/§37)'

# --- Teste silenciado (§48) ---
scan '\b(it|test|describe)\.(skip|only)\(|xit\(|xdescribe\(' 'teste pulado/only esquecido (§48/§37)'

# 3) §43.3 — checagem de CSP/headers quando há config de framework no diff
cfgchg=$(git diff --name-only "$BASE"...HEAD 2>/dev/null \
  | grep -E '(next\.config\.(js|mjs|ts)|astro\.config\.(mjs|ts)|middleware\.(ts|js)|vercel\.json|netlify\.toml)$' || true)
if [[ -n "$cfgchg" ]]; then
  hassec=$(git diff "$BASE"...HEAD -- $cfgchg 2>/dev/null \
    | grep -iE 'content-security-policy|strict-transport-security|x-content-type-options' || true)
  [[ -z "$hassec" ]] && warn "config de framework alterada sem tocar em headers de segurança (CSP/HSTS) — confira (§43.3)"
fi

# 4) §46 — sitemap à mão (deve ser gerado)
manual=$(git diff --name-only "$BASE"...HEAD 2>/dev/null | grep -E '(^|/)(public/)?sitemap\.xml$' || true)
if [[ -n "$manual" ]]; then
  gen=$(git diff --name-only "$BASE"...HEAD 2>/dev/null | grep -E 'gen-sitemap|sitemap\.(ts|js|mjs)$' || true)
  [[ -z "$gen" ]] && warn "sitemap.xml editado à mão sem o gerador no diff — sitemap deve ser autogerado (§46)"
fi

# 5) §39 — índice atualizado quando muda componente/funcionalidade
if (( ${#FILES[@]} > 0 )); then
  idx=$(git diff --name-only "$BASE"...HEAD 2>/dev/null | grep -E 'INDEX_(GLOBAL|COMPONENTS)\.md' || true)
  [[ -z "$idx" ]] && warn "diff mexe em código mas não toca INDEX_*.md — índice atualizado? (§39)"
fi

# 6) §40 — backend disfarçado / linguagem fora de escopo
back=$(git diff --name-only "$BASE"...HEAD 2>/dev/null | grep -E '\.(php)$' || true)
[[ -n "$back" ]] && block "arquivo PHP no diff — fora de escopo; backend é Go/Rust no schematize-go (§40): $back"

echo
if (( FAIL )); then
  echo "${RED}== check-diff: BLOQUEADO ==${RST}"; exit 1
else
  echo "${GRN}== check-diff: OK ==${RST}"; exit 0
fi
