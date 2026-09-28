# orders-api — agent instructions

A tiny Express + TypeScript API with an in-memory store, carrying the controls
from the previous workshop. The feature to build is `POST /orders`; its spec
arrives via `/plan orders <path>` and lands in `docs/specs/orders.md`.

## Commands

| Task           | Command             |
| -------------- | ------------------- |
| Tests          | `npm test`          |
| Typecheck      | `npm run typecheck` |
| Everything     | `npm run verify`    |
| Run the server | `npm run dev`       |

`npm run verify` is the definition of green; the pre-push hook runs exactly
this. Tests hit the app factory directly (`createApp()`), no server needed.

## Layout

- `src/app.ts` — factory. `src/store.ts` — in-memory data with `reset()`.
- `src/routes/` — one router per resource. `src/schemas.ts` — zod schemas.
- `tests/` — vitest + supertest, one file per resource.
- `docs/specs/` — the contract, copied in by `/plan` from the product's spec.
  **Read-only for agents after that.**
- `docs/plans/` — the plan behind every change (`/plan`). See "Plans" below.

## WON'T — hard prohibitions

- **WON'T edit anything under `docs/specs/`.** If the spec is wrong or
  ambiguous, say so in your output; never change the spec to match the code.
- **WON'T delete, weaken or skip a test assertion to make a suite pass.** A red
  test is information.
- **WON'T commit or push unless explicitly asked.** `/ship` asks; a push to
  main, a force-push, or `--no-verify` is blocked outright.
- **WON'T add a dependency without saying why.**

## Plans

Every meaningful change gets a plan in `docs/plans/NNN-slug.md`, and the
commit that implements it carries the trailer

```
Plan: docs/plans/001-orders-endpoint.md
```

The `commit-msg` hook rejects commits without it.

## Verify before claiming

"It typechecks" is not "it works". Run `npm test` before reporting done. When
you report, list which acceptance criteria (AC1…AC8 in the spec) you covered and
which you did not.

## What is enforced vs. advisory

This file is advisory. The things that matter are enforced where an agent can't
disable them: permission rules and hooks in `.claude/settings.json`, and git
hooks in `.husky/`. If a tool
call is blocked, **that is the guardrail working — do not route around it.**
Say what you wanted to do and why, and let the human decide.
