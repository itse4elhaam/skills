# Conditional review checks

Read the section routed by the relevant lens. Apply it to the changed contract and its affected callers.

## Test confidence

- **Black-box testing.** Exercise the public consumer path with real internal wiring; fake external boundaries. Prefer integration tests for permutations, browser/native-UI tests for environment-specific behavior.
- **Database guarantees.** Test authorization, constraints, transactions, and concurrency against real database behavior. Include legitimate success alongside rejection.
- **Independent expectations.** Use known outcomes, not the implementation to calculate its own expected answer.
- **Production fidelity.** Packaging changes need the built/installed entry point. Test counts, source-text checks, and isolated helper tests alone do not prove the shipped journey.
- **Evidence.** State what ran, what was simulated, what remains unverified, and whether CI runs the relevant suite.
- **Scenario choice.** Pick scenarios from the conditions that change execution: feature enabled or disabled, fresh or persisted state, slow or failed dependencies. For asynchronous UI, verify eventual recovery and the next user action. Assert external-call counts and blocking behavior next to returned values.
- **Mutation check.** For critical rules, break the rule (by hand or with focused mutation testing) and watch the test go red.

## Stateful workflows

For payments, bookings, multi-step writes, or jobs with side effects:

- Identify the authoritative state and allowed transitions. Trace failure at step n after an earlier step has committed or caused an external effect. A timeout or lost response may leave the outcome unknown.
- Check retry limits, idempotency scope, changed payloads, duplicate/out-of-order requests, and overlapping attempts where they can occur. A disabled button or process-local lock is not proof of server or distributed concurrency safety.
- Follow recovery after tab closure, reload, process restart, or exhausted retries. Name who owns reconciliation and how the user or operator learns the eventual outcome. Verify provider-owned recovery before proposing another app-side queue or ledger.
- Keep UI feedback consistent with authoritative state. Pending or unknown must not become a false failure, premature success, or an invitation to repeat an irreversible action. Preserve recoverable state and verify promised notifications.

## Whole-flow tracing

- **Promise groups.** Distinguish rejected promises from returned error values. Check partial success and what a retry repeats.
- **Shared hooks, middleware, and workflows.** List the user actions that trigger them. Trace each awaited database or API call to completion and ask whether that action needs the work before returning. Check timeouts, retries, and queued writes. Separate immediate optimistic UI feedback from actual request completion.
- **Loading flags, locks, pending counters, disabled controls.** Trace entry and exit through success, failure, cancellation, and overlapping operations. Verify that completion updates every consumer, including same-tab state and cross-tab listeners.

## Rollout and migrations

- **Old and new code overlap during a deploy.** A schema change works with both: add before the first reader, remove after the last. Check lock time and backfill cost on large tables.
- **Contracts outlive the deploy.** A changed API shape, event payload, cached value, or stored JSON still works for existing clients, queued jobs, and persisted rows.
- **Config exists everywhere.** A new environment variable, flag, or secret is set in every environment and documented, and the code is safe when it is missing.
- **Rollback is named.** State how the change is reverted, and how data is restored after a destructive migration.

## Foot guns

Sweep the ones the diff can reach. A reachable one on a sensitive path is a Blocker.

- **Silent failure.** An empty catch, an unawaited promise, a swallowed rejection, a fallback value that hides an error.
- **Unbounded work.** A query with no limit or pagination, an await per item in a loop, an uncapped list, a new filter or sort with no index behind it.
- **Check then write.** A read followed by a write that assumes nothing changed in between: stock, balances, slots, uniqueness with no database constraint.
- **Time and money.** Date math across time zones or daylight saving, server time shown as user time, floating-point currency, rounding at different steps.
- **Leaks.** A secret or server-only variable in the client bundle; tokens or personal data in logs, error messages, or URLs.
- **Stale state.** A cache key the write leaves valid, optimistic UI with no rollback, an Effect that refetches or loops.
- **Forms and UI states.** Double submit, validation only in the browser, input lost on error, a missing loading, empty, or error state, a control with no label or keyboard path.

## React and Next.js

- Classify exports by caller and effect. For example, in Next.js repositories following the action/route convention: client-triggered mutations use server actions with auth/ownership checks; public/client-readable GET access uses route handlers; internal reads/shared logic use `server-only` helpers.
- Do not export read/query helpers as `use server` actions just for reuse: these exports are callable actions. Respect the repo's framework and existing HTTP contracts, including webhooks.
- Keep `use client` at the smallest boundary that needs browser state or events; check whether a server shell can render that client component. Preserve SSR and server-only data access.
- Prefer derived values or event handlers when they express the actual cause. An Effect may be needed to synchronize with an external system, including browser history. Trace navigation and synchronization requirements before removing it.
