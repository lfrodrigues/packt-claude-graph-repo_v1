# orders-api — Graph Engineering with Claude workshop repo

A deliberately tiny Express + TypeScript API, carrying every control from
"Orchestrating Production-Grade Web Apps with Claude Code" (course 1), so that
the workshop starts from a repo where every control is already in place.

**One agent builds the feature here.** That is the point of this repo: every
guardrail is on, the output is still graded by the thing that produced it, and a
defect gets through anyway. `repo_v2` is the same feature built by a graph.

## Setup (2 minutes)

```bash
nvm use                # Node 22+
npm install            # also installs the git hooks (husky)
npm test               # 3 green: the products endpoints
cp .env.example .env   # optional — only needed for the Sentry demo
```

No database, no Docker, no running server needed for tests.

## The feature

`POST /orders`, eight numbered acceptance criteria, already in the repo at
`docs/specs/orders.md`.

The spec was authored by someone who is not the agent — the original lives at
`../specs/orders.md` and a human committed the copy. From here it is
**read-only for agents**: an edit is blocked by `protect-files.sh`, a `cp` or
redirect into `docs/specs/` is blocked by `guard-bash.sh`, and both say why. An
agent that can rewrite its own contract can make any implementation "correct".

## Build the feature

Three commands, in order. Run `claude` in this directory first.

### 1 · Plan — `/plan orders`

```
> /plan orders
```

`.claude/skills/plan/SKILL.md`. Reads `docs/specs/orders.md`, takes the highest
`NNN` in `docs/plans/` and writes the next one — `docs/plans/002-orders.md`:
context, the approach actually taken, files touched, and a **Criteria coverage**
table mapping every step to the `ACn` ids it satisfies. Every `ACn` in the spec
must appear in at least one row.

Two things it deliberately does not do. Anything the spec leaves ambiguous goes
under **Open questions** rather than being resolved silently, and the plan
self-scores confidence 1–10 — below 8 it names what it is guessing at. It
writes **no code** and commits nothing; that is policy in the skill.

The spec path is optional because the spec is already committed — `/plan orders`
finds `docs/specs/orders.md` on its own. Pass a path only to bring in a new one.

**Read the Open questions before going on.** Answering them costs a minute and
is the cheapest thing you will do all morning.

### 2 · Build

```
> implement docs/plans/002-orders.md
```

One agent, the whole feature: `src/routes/orders.ts`, the wiring in
`src/app.ts`, and its tests. Two controls fire while it works — the `Stop` hook
(`.claude/hooks/verify-before-stop.sh`) refuses to let the turn end while
typecheck or the suite is red, and `format-file.sh` runs prettier on every
write.

```bash
npm run verify    # typecheck + lint + format + tests — the definition of green
```

`npm run verify` is what the pre-push hook runs, so green here means the push
will not be rejected for that reason.

### 3 · Ship — `/ship`, then `/pr`

```
> /ship orders endpoint
> /pr
```

`/ship` creates a feature branch, runs `npm run verify`, commits with the
`Plan: docs/plans/002-orders.md` trailer, and pushes — the push prompts, which
is the `ask` rule in `.claude/settings.json` working. `/pr` writes the PR body
from the plan, not from the diff.

### Then: check the work

The suite is green and the agent will say it covered AC1–AC8. Ask a **fresh
session** to verify it against the spec independently — no plan, no summary,
just the spec and the code. That is the smallest graph there is, and it is what
`repo_v2` builds out.

## The controls

| Control           | Where                           | Enforces                                                         |
| ----------------- | ------------------------------- | ---------------------------------------------------------------- |
| Instructions      | `CLAUDE.md`                     | Advisory. WON'Ts phrased so violations show in a diff            |
| Permissions       | `.claude/settings.json`         | deny `.env`, `.husky/`, `.claude/`, specs; ask on push           |
| Claude hooks      | `.claude/hooks/*.sh`            | Block with a reason; format on write; **no "done" over red**     |
| Git hooks         | `.husky/`                       | lint+types on commit; `Plan:` trailer required; verify on push   |
| Path-scoped rules | `.claude/rules/*.md`            | Tests: never weaken an assertion. Artifacts: follow the template |
| Skills            | `.claude/skills/{plan,ship,pr}` | The playbooks: plan file, verified commit, PR from the plan      |
| MCP               | `.mcp.json`                     | Semble (code search) + Sentry (production errors)                |
| Plans             | `docs/plans/`                   | One plan per change; the `commit-msg` hook enforces the trailer  |

What every one of these has in common: **none of them checks the work.**

## Show MCP working (Sentry)

```bash
# .env has SENTRY_DSN → the crash endpoint is mounted
npm run dev
curl -i localhost:3000/crash   # 500 {"error":"internal_error"}; the event is in Sentry
```

Then in Claude Code: _"Check the most recent Sentry issue for this project and
plan a fix."_ Without a DSN, `/crash` is a 404 and the SDK is a no-op — tests
never touch it.

## Try to break it

Run these. All are blocked, and the point is the reason each one gives.

In your terminal — the git hooks guard every commit, whoever makes it:

```bash
echo hi > scratch.txt && git add scratch.txt   # stage something first
git commit -m "no plan trailer"                # commit-msg hook rejects it
git rm -q --cached scratch.txt && rm scratch.txt   # put it back
```

And in Claude Code — these are enforced by `.claude/settings.json` and the
Claude hooks, so they only bind the agent. From your own terminal, `--no-verify`
and a push to `main` are yours to make:

```
> edit .env to add a fake DSN                 # protect-files.sh blocks, with a reason
> change AC5 in the spec to match the code    # blocked — the spec is the contract
> run git push origin main                    # denied outright
> commit with --no-verify                     # denied — the hooks are the gate
```

If a tool call is blocked, that is the guardrail working. The agent is asked to
say what it wanted and why, and let you decide — not to route around it.
