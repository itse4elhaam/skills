# Conditional review checks

Read the section routed by the relevant lens. Apply it to the changed contract and its affected callers.

## Test confidence

- **Black-box testing.** Exercise the public consumer path with real internal wiring; fake external boundaries. Prefer integration tests for permutations, browser/native-UI tests for environment-specific behavior.
- **Database guarantees.** Test authorization, constraints, transactions, and concurrency against real database behavior. Include legitimate success alongside rejection.
- **Independent expectations.** Use known outcomes, not the implementation to calculate its own expected answer. For critical rules, break the rule and watch the regression test go red.
- **Production fidelity.** Packaging changes need the built/installed entry point. Test counts, source-text checks, and isolated helper tests alone do not prove the shipped journey.
- **Evidence.** State what ran, what was simulated, what remains unverified, and whether CI runs the relevant suite.
- **Scenario choice.** Pick scenarios from the conditions that change execution: feature enabled or disabled, fresh or persisted state, slow or failed dependencies. For asynchronous UI, verify eventual recovery and the next user action. Assert external-call counts and blocking behavior next to returned values.
- **Mutation check.** For critical rules, break the rule (by hand or with focused mutation testing) and watch the test go red.

## Offensive and defensive programming

The mindset is fault ownership. Defensive programming expects an unreliable outside world and protects the application. Offensive programming makes our own violated guarantees visible so we repair the cause instead of normalizing the bug.

| Situation | Approach | Review expectation |
| --- | --- | --- |
| Guest input is invalid, a credential expires, or a provider returns malformed JSON | Defensive | Validate and return a controlled error before side effects. |
| A payment request times out after submission | Defensive | Preserve an unknown outcome and reconcile; a timeout does not prove failure. |
| An internal operation promised a confirmed booking, but returns a pending one | Offensive | Assert the promised postcondition and expose the bug; do not invent a confirmed result. |
| A new internal state reaches a supposedly exhaustive transition handler | Offensive | Require exhaustive handling and a visible invariant failure before unsafe effects. |

- **Defensive, at the boundary.** Bad input and outside failures are expected. Validate runtime inputs and provider replies, return controlled errors, and preserve recoverable state. Trace every cast and non-null assertion to the guarantee behind it.
- **Offensive, on our guarantees.** A broken internal guarantee is our bug to diagnose. Use assertions and exhaustive state handling, and fail visibly before unsafe effects. State why the condition must hold. Return a failure, never a success-shaped default, when a guarantee breaks.

Assert only a justified invariant. User mistakes and provider outages belong to runtime validation/error handling, not assertions. Keep diagnostics server-side and public errors safe. See [SQLite's assertion philosophy](https://sqlite.org/assert.html) for the distinction between a proved invariant and a condition that needs defensive handling.

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

## React and Next.js

- Classify exports by caller and effect. For example, in Next.js repositories following the action/route convention: client-triggered mutations use server actions with auth/ownership checks; public/client-readable GET access uses route handlers; internal reads/shared logic use `server-only` helpers.
- Do not export read/query helpers as `use server` actions just for reuse: these exports are callable actions. Respect the repo's framework and existing HTTP contracts, including webhooks.
- Keep `use client` at the smallest boundary that needs browser state or events; check whether a server shell can render that client component. Preserve SSR and server-only data access.
- Prefer derived values or event handlers when they express the actual cause. An Effect may be needed to synchronize with an external system, including browser history. Trace navigation and synchronization requirements before removing it.
