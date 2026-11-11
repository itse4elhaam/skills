---
name: elhaam-review
description: Reviews code changes the way Elhaam does. Use when reviewing a pull request, branch, local diff, or agent-written change, or when another skill needs review findings to adjudicate or post.
---

# Elhaam Review

Review every hunk against the system it lands in. A change ships when it **earns its place**, **fits the codebase**, **reads like English**, treats every server export as a **public endpoint**, carries tests that **earn their place**, and **fixes the cause once** so the next caller is protected.

Judgement drives the review; the [output contract](#output-contract) is fixed. Before step 4, read [`references/house-style.md`](references/house-style.md): Elhaam's own comments, grouped by lens. The repo's `AGENTS.md`, `CONTRIBUTING.md`, and lint config win when they disagree.

## Steps

1. **Read the diff and every changed file.** Record base and head, the promised user outcome, its non-goals, and the touched layers. Mark each file's risk: sensitive (auth, payments, data writes, migrations, public endpoints), logic, or presentation.
   Done when every changed file has a risk mark.
2. **Search before judging.** Find the existing helpers, constants, types, server and data patterns, tests, and names near each hunk. Read the repo's agent docs and lint config.
   Done when you know the local convention for every hunk you will comment on.
3. **Collect review threads.** For a GitHub PR, use `/github-graphql-first` when available; otherwise query GraphQL `reviewThreads` directly, because REST flattens thread context.
   Done when every thread and reply is collected, including resolved and outdated ones, and each claimed fix is checked against current code as implemented, deferred, or withdrawn.
4. **Apply every lens to every hunk.** Then try to falsify each candidate: check callers, validation, installed versions, author replies, and product intent. Name the actor, action, and state, the observable failure, and the causal path. Static proof can be enough.
   Done when each surviving finding has a severity, its evidence, and its smallest fix, and defects, standards feedback, confidence gaps, and questions stay distinct.
5. **Deliver** using the [output contract](#output-contract).
   Done when the HTML report exists. Publish nothing unless the current request explicitly says to.

## Lenses

### 0. Earns its place

Every hunk answers "why is this here?" Ask about whatever the PR and issue leave unexplained: a lockfile change, a removed guard, a new dependency, an unrelated refactor.

- Removal: the replacement exists first, and its consumers move in the same change. Docs, guides, and tests count.
- Scope: one concern per PR. Flag unrelated commits, a stale base, or the wrong target branch before line comments.
- Commented-out code and dead branches are deleted, not kept.

### 1. Fits the codebase

- Reuse the existing helper (`tryCatch`, `safeParse`, the shared fetcher, formatters, query helpers). If none exists and the operation repeats, create one generic helper and use it everywhere.
- Shared concepts live where the repo keeps them: types, constants under one object, enums.
- **Single source of truth.** Give shared policy one owner and check that real callers use it. Share meaning, not values that happen to be equal.
- A new pattern needs a stated reason; otherwise align with the local one.
- Name good patterns so the author repeats them.

### 2. Reads like English

Before suggesting a simpler shape, name the behavior, edge cases, auth, UX, and API contracts that must survive. Simpler code keeps every consumer's specialized behavior.

- Guard clauses instead of nesting and `else` after return.
- One-level ternaries at most; past that, use a map, a function, or a component with a guard.
- Extract a named variable or function where logic stops reading like a sentence. Use full words in names.
- Keep private helpers and components in the file that uses them. Keep comments that explain constraints or reasons.
- Check branch count (cyclomatic complexity) against the repo's lint limit. Simplify decisions, not just length.
- A generic utility only when the operations share a shape.
- Assumptions are explicit, not hidden in branches or magic strings: tenant scope, ordering, data shape, flags, retries, time zones, nullability.
- The next engineer adds one more case in one place, without copying fragile code.

### 3. Tests earn their place

Proof scales with risk; existing tests can supply it.

- Test what the user does and sees, through the public path. A test of internals, snapshots of constants, or CSS classes gets deleted, not extended.
- A browser or integration test names the failure that cheaper tests miss and is worth its CI time. A full checkout journey qualifies; a button's styling does not.
- Run only the checks the change can affect. A CSS change gets a visual check, not the full suite.
- Logic or transformed data gets focused unit tests. Sensitive paths get several scenarios, not one manual happy path. Include the legitimate case next to the rejected one.
- For a critical rule, show the test goes red when the rule breaks.
- UI changes ship with a screenshot or video. Check long text, empty states, and mobile width.
- For scenario choice, async UI, database and packaging fidelity, read [test confidence](references/conditional-checks.md#test-confidence).

### 4. Public endpoint

Treat server and data boundaries as attack surface until a trace proves otherwise.

- Classify every export by caller and effect. Every exported function in a `use server` file is a public POST endpoint, whatever its name says.
- Every database access proves authentication, ownership or tenant scope, null handling, failure behavior, and IDOR resistance. Trace the enforcement path; authentication alone does not prove ownership.
- Return only data the caller may see. Filter to public rows at the data layer.
- Client errors stay generic; detail goes to server logs.
- `use client` is an island: put it on the smallest component that needs browser state.
- Distrust the outside world (defensive); fail fast on our own broken guarantees (offensive). Read [offensive and defensive programming](references/conditional-checks.md#offensive-and-defensive-programming) when choosing.
- For React or Next.js, read [framework boundaries](references/conditional-checks.md#react-and-nextjs).

### 5. Whole flow

Look across hunks. Hunks that are fine alone can add up to N+1 queries or repeated work.

- Count database, API, and job calls across the full request, including loops and `Promise.all`. Decide whether one failure should fail everything and how partial success recovers.
- Check caching, ISR or SSG, background jobs, and type mismatches against production data. Ask what happens with more users, tenants, records, flags, and retries.
- For payments, bookings, multi-step writes, or side-effect jobs, read [stateful workflows](references/conditional-checks.md#stateful-workflows).
- For shared hooks, middleware, loading flags, and locks, read [whole-flow tracing](references/conditional-checks.md#whole-flow-tracing).

### 6. Fix the cause once

Prevention closes the review. Every repeatable finding gets a durable control (a test, a lint or type rule, a shared helper, a line in `AGENTS.md`, or a skill update) and names what would prove it works.

- If an existing rule should have caught it, check why it did not: discovery, configuration, coverage, or not running.
- Put the control at the shared boundary so the next caller is protected. Group symptoms by cause; leave unrelated cleanup as a follow-up.
- For a new or cited control, show one violating case fails and one legitimate case passes. Say whether it is documented, runnable locally, running in CI, or required before merge.

## Severity

| Level | Meaning | Group |
| --- | --- | --- |
| P1 | Security hole, data loss, wrong money or booking, broken behavior, or no proof on a sensitive path | Blockers |
| P2 | Maintainability: duplicated or misplaced code, hard to read, convention break with a named cost, a test of internals | Should fix |
| P3 | Minor or unproved concern, worth a question | Should fix or Follow-ups |

Severity follows impact, not category; confidence states how well the premise is proved. A confidence gap is P1 when the unproved behavior carries material risk. Sensitive paths need more than one tester before merge: reliability beats shipping speed.

## Output contract

Apply `no-bs` and `unslop` to every word the user or an author reads. Resolve each by name through the skill tool or installed skills directories. If one cannot be read, say so once and write plainly. Keep exact code, paths, quotes, evidence, uncertainty, and severity through every edit. Check that a reader new to the code can say what breaks, when, why it matters, and what to do next.

### HTML report (always)

Write a standalone HTML file with `/readable-html-dossier` when available, otherwise self-contained HTML with inline CSS. Also give Markdown when asked.

1. Conclusion and the most important consequence for the user.
2. A short explanation of the feature or workflow under review.
3. Scope and revision, evidence links, and what remains unverified.
4. Findings under **Blockers**, **Should fix**, **Teach-back** (good patterns and prevention), and **Follow-ups**. Omit empty groups. Report a clean review when it is clean.
5. Prevention controls from lens 6, and the output path.

Each finding has a title naming the consequence, the trigger and condition, the expected and actual behavior, the cause, and the smallest fix in full sentences. Put `path:line` and evidence beside it; keep long traces in an evidence section. A simple issue gets a short finding. The scenario below is illustrative:

```md
### [P1 correctness] Retrying checkout can charge the customer twice

If a payment succeeds but its response times out, the customer sees a failure
and can retry. The retry sends a new payment request, so the customer can be
charged again for the same order.

In `src/checkout.ts:42`, each attempt creates a new payment identifier. Reuse
one identifier for the order and check the first payment's status before
creating another charge.

The code path shows how a second charge can occur. A timeout-and-retry test
has not been run.
```

### Inline comment (when drafting PR comments)

One to three sentences in Elhaam's voice: name the trigger and consequence, then the fix. Ask a question when the author may know something you do not. Add one source link when it teaches (react.dev, refactoring.guru, the testing trophy). Praise a good pattern in one line. `house-style.md` has real examples.

```md
The token only lives in `modelMessages`, and the next request rebuilds history
from UI text, so it is gone by the confirm step. Can the server own the
transcript per `chatSessionId`?
```

Publish inline comments only when the current request explicitly says to. Then hand off to `/posting-pr-review-comments`, which revalidates the PR and posts one batched review. The same writing rules carry into that handoff. Requests to review or preview stay read-only.

For handoffs, give the user outcome, rationale, constraints, and acceptance evidence. Leave slice planning to the engineer unless asked.

## Discipline

- Separate what the diff proves from production hypotheses: when code was introduced, deployed, activated, and when the symptom began. Measure latency or label it unmeasured.
- Every style flag names its maintenance cost.
