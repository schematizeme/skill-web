#!/usr/bin/env bash
# smoke-selfcheck.test.sh — prova o contrato do self-check contra um servidor HTTP local de mentira:
# VERDE (esperar 0) com site saudável; VERMELHO (rc != 0) com home sem <title>; --self-check
# precisa sair 0 (o runner viu a falha forçada). Sem rede externa: python3 -m http.server em 127.0.0.1.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# harness de teste roda sem `-e` de propósito — precisa reportar TODOS os casos.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
W="$(mktemp -d)"; PIDS=()
trap 'for p in "${PIDS[@]:-}"; do [ -n "$p" ] && kill "$p" 2>/dev/null; done; rm -rf "$W"' EXIT
command -v python3 >/dev/null && command -v curl >/dev/null || { echo "smoke-selfcheck.test: python3/curl ausentes — nada provado"; exit 2; }
rc=0
sobe() { # dir -> porta (stdout)
  local porta; porta=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
  ( cd "$1" && exec python3 -m http.server "$porta" --bind 127.0.0.1 >/dev/null 2>&1 ) &
  PIDS+=("$!")
  for _ in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$porta/" && break; sleep 0.1; done
  echo "$porta"
}
espera() { local nome="$1" esperado="$2" obtido="$3"
  if [ "$obtido" = "$esperado" ]; then echo "  ok  $nome (rc=$obtido)"
  else echo "  FALHA $nome: rc=$obtido, esperado $esperado"; rc=1; fi; }
espera_nao0() { local nome="$1" obtido="$2"
  if [ "$obtido" != 0 ]; then echo "  ok  $nome (rc=$obtido)"
  else echo "  FALHA $nome: passou com rc 0, esperado != 0"; rc=1; fi; }

mkdir -p "$W/bom" "$W/cego"
printf '<!doctype html><html><head><title>Loja</title></head><body><h1>Oi</h1></body></html>\n' > "$W/bom/index.html"
printf '<html><body>{{ placeholder }} undefined</body></html>\n' > "$W/cego/index.html"
P1=$(sobe "$W/bom"); P2=$(sobe "$W/cego")

BASE_URL="http://127.0.0.1:$P1" bash "$HERE/smoke-selfcheck.sh" >/dev/null 2>&1; espera "VERDE: site saudavel, modo normal" 0 "$?"
BASE_URL="http://127.0.0.1:$P1" bash "$HERE/smoke-selfcheck.sh" --self-check >/dev/null 2>&1; espera "VERDE: --self-check sai 0 (viu a falha forcada)" 0 "$?"
BASE_URL="http://127.0.0.1:$P2" bash "$HERE/smoke-selfcheck.sh" >/dev/null 2>&1; espera_nao0 "VERMELHO: home sem <title>/com placeholder reprova" "$?"

[ "$rc" = 0 ] && echo "smoke-selfcheck: todos os casos ok" || echo "smoke-selfcheck: HÁ FALHAS"
exit "$rc"
