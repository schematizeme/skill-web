#!/usr/bin/env bash
# archive-secret-scan.test.sh — vermelho e verde do scanner de segredo no archive.
# Segredos/PII falsos são MONTADOS em tempo de execução (o push protection do GitHub bloqueia
# literais). Força o caminho por regex (PATH sem gitleaks) para o teste ser determinístico.
# Saída: exit 0 todos os casos passam - exit 1 algum caso falhou.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# harness de teste roda sem `-e` de propósito — precisa reportar TODOS os casos.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
rc=0
# PATH sem gitleaks: links só para o que o script usa.
BIN="$W/bin"; mkdir -p "$BIN"
for c in bash grep sed head find; do ln -s "$(command -v "$c")" "$BIN/$c"; done
roda() { PATH="$BIN" "$(command -v bash)" "$HERE/archive-secret-scan.sh" "$1" >/dev/null 2>&1; echo $?; }
espera() { local nome="$1" esperado="$2" obtido="$3"
  if [ "$obtido" = "$esperado" ]; then echo "  ok  $nome (rc=$obtido)"
  else echo "  FALHA $nome: rc=$obtido, esperado $esperado"; rc=1; fi; }

# VERDE 1: sem pasta de archive, nada a varrer, esperar 0.
mkdir -p "$W/vazio"; espera "sem archive: nada a varrer" 0 "$(roda "$W/vazio")"
# VERDE 2: archive limpo, esperar 0.
mkdir -p "$W/limpo/p_archive/context"; echo "# handoff limpo, sem segredo" > "$W/limpo/p_archive/context/a.md"
espera "archive limpo passa" 0 "$(roda "$W/limpo")"

# VERMELHO 1: chave estilo AWS montada em runtime.
mkdir -p "$W/aws/p_archive"; printf 'chave: %s%s\n' "AKIA" "ABCDEFGHIJKLMNOP" > "$W/aws/p_archive/h.md"
espera "chave AWS no archive reprova" 1 "$(roda "$W/aws")"
# VERMELHO 2: CPF (PII) montado em runtime.
mkdir -p "$W/cpf/p_archive"; printf 'cpf %s.%s.%s-%s\n' 123 456 789 09 > "$W/cpf/p_archive/h.md"
espera "CPF no archive reprova" 1 "$(roda "$W/cpf")"
# VERMELHO 3: bloco de chave privada montado em runtime, em .jsonl.
mkdir -p "$W/pk/p_archive"; printf '%s %s %s\n' "-----BEGIN" "RSA PRIVATE" "KEY-----" > "$W/pk/p_archive/t.jsonl"
espera "chave privada em .jsonl reprova" 1 "$(roda "$W/pk")"
# Fora do archive não é varrido (contrato do glob): esperar 0.
mkdir -p "$W/fora"; printf 'k %s%s\n' "AKIA" "ABCDEFGHIJKLMNOP" > "$W/fora/readme.md"
espera "segredo fora de *_archive/ nao e escopo" 0 "$(roda "$W/fora")"

[ "$rc" = 0 ] && echo "archive-secret-scan: todos os casos ok" || echo "archive-secret-scan: HÁ FALHAS"
exit "$rc"
