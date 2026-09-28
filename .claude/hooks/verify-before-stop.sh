#!/usr/bin/env bash
# Stop hook: if src/ or tests/ were modified, run typecheck + tests and refuse
# to end the turn (exit 2) while they fail. This is a deterministic quality
# gate: the agent cannot report "done" over a red suite, whatever it believes.
set -u

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo_root" || exit 0

git status --porcelain 2>/dev/null | grep -qE '^.. (src|tests)/' || exit 0

# Avoid re-fire loops: if we already blocked once this turn, let it end.
if command -v jq >/dev/null 2>&1; then
  stop_active=$(jq -r '.stop_hook_active // false' 2>/dev/null)
  [ "$stop_active" = "true" ] && exit 0
fi

out=$(npm run typecheck --silent 2>&1 && npm test --silent 2>&1)
status=$?

if [ $status -ne 0 ]; then
  echo "GATE: typecheck or tests failing on modified files — fix before finishing:" >&2
  echo "$out" | tail -30 >&2
  exit 2
fi
exit 0
