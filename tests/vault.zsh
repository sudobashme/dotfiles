#!/usr/bin/env zsh
set -euo pipefail

typeset -r TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/lamina-vault-test.XXXXXXXX")"
trap '/bin/rm -rf -- "${TEST_ROOT}"' EXIT INT TERM

typeset -r FIXTURE_HOME="${TEST_ROOT}/home"
typeset -r STAGE_ROOT="${TEST_ROOT}/stage"
mkdir -p \
    "${FIXTURE_HOME}/.grok/memory/project" \
    "${FIXTURE_HOME}/.grok/sessions/example/terminal" \
    "${FIXTURE_HOME}/.openclaw/agents/main/sessions" \
    "${FIXTURE_HOME}/Library/Application Support/Cursor/User/globalStorage"

print -r -- '# remembered fact' > "${FIXTURE_HOME}/.grok/memory/MEMORY.md"
print -r -- 'keep' > "${FIXTURE_HOME}/.grok/sessions/example/chat_history.jsonl"
print -r -- 'discard' > "${FIXTURE_HOME}/.grok/sessions/example/chat_history.jsonl.lock"
print -r -- 'discard' > "${FIXTURE_HOME}/.grok/sessions/example/terminal/tool.log"
print -r -- 'keep' > "${FIXTURE_HOME}/.openclaw/agents/main/sessions/current.jsonl"
print -r -- 'discard' > "${FIXTURE_HOME}/.openclaw/agents/main/sessions/current.jsonl.bak-1"

/usr/bin/sqlite3 "${FIXTURE_HOME}/.grok/memory/project/index.sqlite" \
    'CREATE TABLE memory (value TEXT); INSERT INTO memory VALUES ("durable");'

LAMINA_VAULT_HOME="${FIXTURE_HOME}" "${0:A:h:h}/bin/lamina" vault stage --output "${STAGE_ROOT}" >/dev/null

[[ -f "${STAGE_ROOT}/grok/memory/MEMORY.md" ]]
[[ -f "${STAGE_ROOT}/grok/sessions/example/chat_history.jsonl" ]]
[[ ! -e "${STAGE_ROOT}/grok/sessions/example/chat_history.jsonl.lock" ]]
[[ ! -e "${STAGE_ROOT}/grok/sessions/example/terminal/tool.log" ]]
[[ -f "${STAGE_ROOT}/openclaw/agents/main/sessions/current.jsonl" ]]
[[ ! -e "${STAGE_ROOT}/openclaw/agents/main/sessions/current.jsonl.bak-1" ]]
[[ "$(/usr/bin/sqlite3 "${STAGE_ROOT}/grok/memory/project/index.sqlite" 'SELECT value FROM memory;')" == durable ]]
[[ "$(/usr/bin/sqlite3 "${STAGE_ROOT}/grok/memory/project/index.sqlite" 'PRAGMA quick_check;')" == ok ]]
[[ -f "${STAGE_ROOT}/VAULT-MANIFEST" ]]

print -r -- 'vault test: ok'
