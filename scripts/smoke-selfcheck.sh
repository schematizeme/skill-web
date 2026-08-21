#!/usr/bin/env bash
# Smoke · Self-check (anti "verde mentiroso") — frontend
# Prova que o runner CONSEGUE reportar FAIL e que o smoke checa CONTEÚDO,
# não só status. Se este script "passar" quando deveria falhar, o smoke está
# cego e o CI deve quebrar.
#
# Uso:
#   bash smoke-selfcheck.sh               # modo normal: sai 0 se a suite passou
#   bash smoke-selfcheck.sh --self-check  # forca uma falha conhecida:
#                                         #   sai 0 SE o runner reportou o FAIL (e a prova)
#                                         #   sai 1 se NAO reportou (smoke cego)
#
# No CI: rode AMBOS. Normal=0 e --self-check=0-tendo-reportado-FAIL provam que o smoke ve
# verde e vermelho. O --self-check NUNCA sai 1 por ter falhado de proposito: sair 1 ali
# significa que a falha forcada passou despercebida.

set -uo pipefail
_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$_DIR/lib.sh"

BASE="$(api_base)"
MODE="${1:-normal}"

test_section "Smoke · Self-check do runner (frontend)"

# 1) Canário 404: rota fake DEVE devolver 404. 200 aqui = catch-all suspeito.
assert_http_in "rota inexistente devolve 404" "404" GET "$BASE/_smoke_canary_should_404"

# 2) Conteúdo da home: prova que o HTML servido TEM conteúdo, não só 200.
#    Ajuste o needle pro seu projeto (ex.: nome do produto, um <h1> conhecido).
http_call GET "$BASE/"
if [[ "$HTTP_CODE" == "200" ]]; then
  assert_body_contains "home tem <title>" "<title"
  # assertion negativa: sem placeholder/template não renderizado nem erro de hidratação
  assert_body_lacks "home sem placeholder não renderizado" '\{\{|\$\{|%s|undefined|NaN'
else
  test_fail "home não respondeu 200" "HTTP $HTTP_CODE :: $HTTP_BODY"
fi

# 3) Prova viva de que test_fail funciona: em --self-check forçamos falha.
if [[ "$MODE" == "--self-check" ]]; then
  test_fail "falha forçada (esperada no --self-check)" "se você vê isto com exit 0, o runner está quebrado"
else
  test_pass "runner inicializado e capaz de registrar pass"
fi

test_summary "smoke/self-check"

# Contrato do self-check (o codigo abaixo E a definicao; a doc do topo diz o mesmo):
#   modo normal       -> exit = TEST_EXIT_CODE (0 se a suite passou)
#   modo --self-check -> exit 0 SE TEST_EXIT_CODE==1 (o runner reportou a falha forcada)
#                        exit 1 se TEST_EXIT_CODE!=1 (smoke cego: a falha nao foi vista)
if [[ "$MODE" == "--self-check" ]]; then
  if [[ "$TEST_EXIT_CODE" -eq 1 ]]; then
    echo "${C_GRN}self-check OK: o runner reportou FAIL como esperado.${C_RST}"
    exit 0
  else
    echo "${C_RED}${C_BLD}SMOKE CEGO: falha forçada NÃO foi reportada. Conserte o runner.${C_RST}"
    exit 1
  fi
fi

exit $TEST_EXIT_CODE
