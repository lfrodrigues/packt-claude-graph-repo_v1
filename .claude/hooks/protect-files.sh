#!/usr/bin/env bash
# PreToolUse (Edit|Write): block edits to protected paths.
# Exit 2 + stderr = deterministic block; the agent sees the reason.
# This is the layer the permission deny list cannot express: a reason.
set -u

command -v jq >/dev/null 2>&1 || exit 0

file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -n "$file_path" ] || exit 0

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
rel=${file_path#"$repo_root"/}

block() {
  echo "BLOCKED: $rel is protected — $1" >&2
  exit 2
}

case "$rel" in
  .env|.env.*)       block "secrets live here; edit it yourself outside the agent." ;;
  .husky/*)          block "git hooks are a guardrail; change them manually." ;;
  docs/specs/*)      block "the spec is the contract; code must match it, not the other way round. Report the mismatch instead." ;;
  .claude/*)         block "agent config must not be self-modified." ;;
esac

exit 0
