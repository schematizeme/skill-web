#!/usr/bin/env bash
# lib.sh — helpers compartilhados da malha de testes de frontend.
# Source no topo de todo script de teste:
#   source "$_DIR/lib.sh"
#
# Expõe: test_section, test_pass, test_fail, test_skip, test_summary,
#        http_call (popula HTTP_CODE / HTTP_BODY), assert_http_in,
#        assert_body_contains, assert_body_lacks, api_base.
# Contadores e TEST_EXIT_CODE são agregados por test_summary.

# --- cores (degradam pra vazio se não for TTY) -------------------------------
if [[ -t 1 ]]; then
  C_RED=$'\033[0;31m'; C_GRN=$'\033[0;32m'; C_YLW=$'\033[0;33m'
  C_BLU=$'\033[0;34m'; C_BLD=$'\033[1m';   C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_BLU=""; C_BLD=""; C_RST=""
fi

# --- contadores --------------------------------------------------------------
_PASS=0; _FAIL=0; _SKIP=0
TEST_EXIT_CODE=0

# --- config ------------------------------------------------------------------
# Resolve a base do site/app sob teste. Generalize <P>_BASE_URL por projeto.
api_base() {
  echo "${BASE_URL:-${WEB_BASE_URL:-http://127.0.0.1:3000}}"
}

# --- saída -------------------------------------------------------------------
test_section() {
  echo
  echo "${C_BLU}${C_BLD}=== $* ===${C_RST}"
}

test_pass() {
  _PASS=$((_PASS+1))
  echo "  ${C_GRN}✓${C_RST} $1"
}

# test_fail "mensagem" ["corpo/evidência opcional"]
test_fail() {
  _FAIL=$((_FAIL+1))
  TEST_EXIT_CODE=1
  echo "  ${C_RED}✗ $1${C_RST}"
  if [[ -n "${2:-}" ]]; then
    echo "${2}" | head -c 2000 | sed 's/^/      /'
    echo
  fi
}

test_skip() {
  _SKIP=$((_SKIP+1))
  echo "  ${C_YLW}○ skip${C_RST} $1"
}

# http_call METHOD URL [curl-args...]
# Popula HTTP_CODE e HTTP_BODY. Nunca usa "|| true" que esconde erro de rede:
# falha de conexão vira HTTP_CODE=000, que o chamador deve tratar como FAIL.
http_call() {
  local method="$1"; shift
  local url="$1"; shift
  local raw
  raw="$(curl -sS -m 15 -w $'\n__HTTP_CODE__%{http_code}' \
         -X "$method" "$url" "$@" 2>/dev/null)" || raw=$'\n__HTTP_CODE__000'
  HTTP_CODE="${raw##*__HTTP_CODE__}"
  HTTP_BODY="${raw%$'\n'__HTTP_CODE__*}"
}

# assert_http_in "descrição" "200|301" METHOD URL [curl-args...]
assert_http_in() {
  local desc="$1"; shift
  local expect="$1"; shift
  local method="$1"; shift
  local url="$1"; shift
  http_call "$method" "$url" "$@"
  if [[ "$HTTP_CODE" =~ ^($expect)$ ]]; then
    test_pass "$desc (HTTP $HTTP_CODE)"
  else
    test_fail "$desc — esperado [$expect], obtido $HTTP_CODE" "$HTTP_BODY"
  fi
}

# assert_body_contains "descrição" "substring esperada" [URL]
# Smoke de CONTEÚDO: prova que o HTML servido tem o texto/elemento esperado,
# não só que respondeu 200. Se URL for passada, faz GET antes; senão usa HTTP_BODY.
assert_body_contains() {
  local desc="$1"; local needle="$2"; local url="${3:-}"
  [[ -n "$url" ]] && http_call GET "$url"
  if echo "$HTTP_BODY" | grep -qF -- "$needle"; then
    test_pass "$desc (contém: $needle)"
  else
    test_fail "$desc — conteúdo esperado ausente: $needle" "$HTTP_BODY"
  fi
}

# assert_body_lacks "descrição" "regex que NÃO pode aparecer" [URL]
# Assertion negativa: placeholder não renderizado, undefined/NaN, stack trace.
assert_body_lacks() {
  local desc="$1"; local pattern="$2"; local url="${3:-}"
  [[ -n "$url" ]] && http_call GET "$url"
  if echo "$HTTP_BODY" | grep -qiE -- "$pattern"; then
    test_fail "$desc — vazou conteúdo proibido (/$pattern/)" "$HTTP_BODY"
  else
    test_pass "$desc (sem /$pattern/)"
  fi
}

# test_summary "<categoria>/<nome>" — banner ENORME em vermelho se houve falha.
test_summary() {
  local label="${1:-suite}"
  echo
  if [[ "$TEST_EXIT_CODE" -ne 0 ]]; then
    echo "${C_RED}${C_BLD}"
    echo "################################################################"
    echo "##  FALHA EM ${label}"
    echo "##  pass=${_PASS}  fail=${_FAIL}  skip=${_SKIP}"
    echo "################################################################"
    echo "${C_RST}"
  else
    echo "${C_GRN}${C_BLD}── OK ${label}  (pass=${_PASS} skip=${_SKIP}) ──${C_RST}"
  fi
}
