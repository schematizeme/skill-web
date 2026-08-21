#!/usr/bin/env bash
# check-diff.test.sh — o VERMELHO VISTO do gate de frontend (A3 e A3b da vistoria de 2026-08-21).
#
# Motivo: a regra de `<img>` sem alt usava lookahead negativo em POSIX ERE, que NAO o suporta.
# `grep -nE` saia 2 (erro de regex) e o `|| true` do scan() engolia o 2 -> ERRO DE REGEX VIRAVA
# VERDE. O piso de acessibilidade estava morto desde que existe. Este teste monta um repo git
# de mentira com as violacoes plantadas e exige o bloqueio.
# Entrada: nenhuma. Saida: exit 0 todos os casos passam - exit 1 algum caso falhou.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
rc=0

git -C "$W" init -q .
git -C "$W" -c user.email=t@t -c user.name=t commit -q --allow-empty -m base
mkdir -p "$W/src"
printf 'export const a = 1;\n' > "$W/src/limpo.tsx"
git -C "$W" add -A && git -C "$W" -c user.email=t@t -c user.name=t commit -q -m limpo
BASE=$(git -C "$W" rev-parse HEAD~1)

roda() { ( cd "$W" && bash "$HERE/check-diff.sh" "$1" 2>&1 ); }

echo "── A3: <img> sem alt BLOQUEIA (era erro de regex virando verde)"
printf 'export const I = () => <img src="x">;\n' > "$W/src/img.tsx"
git -C "$W" add -A && git -C "$W" -c user.email=t@t -c user.name=t commit -q -m img
OUT="$(roda "$BASE")"; z=$?
if [ "$z" -ne 0 ] && grep -q 'img sem alt' <<<"$OUT"; then echo "  ✔ bloqueou (exit $z)"; else echo "  ✖ passou: $OUT"; rc=1; fi

echo "── A3: <img> COM alt nao bloqueia"
printf 'export const I = () => <img src="x" alt="">;\n' > "$W/src/img.tsx"
git -C "$W" add -A && git -C "$W" -c user.email=t@t -c user.name=t commit -q -m imgalt
OUT="$(roda "$BASE")"
if ! grep -q 'img sem alt' <<<"$OUT"; then echo "  ✔ nao bloqueou (sem falso positivo)"; else echo "  ✖ falso positivo: $OUT"; rc=1; fi

echo "── A3b: erro de grep (exit >= 2) FALHA em vez de virar verde"
cp "$HERE/check-diff.sh" "$W/quebrado.sh"
# planta uma regra com regex sintaticamente invalida (parenteses aberto), ANTES do veredito
python3 - "$W/quebrado.sh" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding="utf8").read()
alvo = "\necho\nif (( FAIL )); then"
s = s.replace(alvo, "\nscan '(sem-fechar' 'regra de teste com regex invalida'\n" + alvo, 1)
open(p, "w", encoding="utf8").write(s)
PY
OUT="$( cd "$W" && bash quebrado.sh "$BASE" 2>&1 )"; z=$?
if [ "$z" -ne 0 ] && grep -q 'grep saiu' <<<"$OUT"; then echo "  ✔ exit $z e 'grep saiu N' (erro nao vira passou)"; else echo "  ✖ engoliu o erro: $OUT"; rc=1; fi

echo
[ $rc -eq 0 ] && echo "✔ check-diff.test.sh: todos os casos" || echo "✖ check-diff.test.sh: falhou"
exit $rc
