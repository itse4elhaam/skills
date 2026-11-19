---
name: offend-and-defend
description: Be defensive about the world and offensive about your own assumptions. Use when writing or reviewing critical code (irreversible work, payments, auth, anything that feeds revenue), when the user mentions invariants, assertions, fail-fast, TigerStyle, or defensive or offensive programming, or when another skill needs these rules.
---

# Offend and defend

Be **defensive** about the world. Bad input, timeouts and provider failures are expected, so handle them and return a controlled error.

Be **offensive** about your own assumptions. When the code produces a state the business rules say cannot exist, throw, close to where it happened. Pretending the state is fine only moves the bug somewhere harder to find.

An **invariant** is a condition that must always hold, such as "a paid order has a payment ID". The person you work with owns the business rules, so you find candidate invariants, propose them and explain them, and they decide.

## Levels

| Level | What it covers | What applies |
| --- | --- | --- |
| Critical | Irreversible work, payments, auth, anything that feeds revenue | Every step below |
| Standard | Ordinary features: articles, profiles, settings | The defend rules; propose an invariant only when it is obvious |
| Throwaway | Prototypes, one-off scripts | Parse input at the edge |

## Steps

1. **Announce.** In two lines, explain it like the reader is five: the skill's name, what you are about to do, and why. Go deeper only when asked.
   Done when the person knows this skill is running and why.
2. **Set the level.** Infer it from what the code touches. When you can't tell, ask the person how important the feature is to the business.
   Done when the level is stated.
3. **Find candidate invariants.** Start from the critical business rules and from what the stored data must obey: an order quantity is positive, a combo deal carries no modifiers, a paid order has a payment ID. Keep looking while you write; when a new candidate appears, ask about it then.
   Done when every critical rule the change touches has been considered.
4. **Propose each one.** Give the state, why it cannot exist, and its guard: a database constraint when the rule is about stored data, an assertion in code, or both. Commit a guard only after the person says yes. With no one to answer, handle the state as an ordinary error and list the candidates in the PR description.
   Done when every candidate has a yes or a no.
5. **Write the guards** using the rules below. Write constraint migrations; run them only when the person says to.
   Done when every confirmed invariant has its guard.
6. **Test** each assertion on critical code twice: a legitimate case that passes it and a broken case that trips it. An assertion is code and can be wrong; `total > 0` blocks a fully discounted order.
   Done when both tests run.

## Defend

- Parse input once at the edge with a tool that returns the error as a value (`safeParse`, a `tryCatch` helper), and pass trusted types inward. Every `use server` export is an edge.
- Return an error value for bad input and outside failures. Retry only reads and idempotent requests, with a limit. A payment retry reuses its idempotency key, so a timed-out charge is never repeated.
- A fallback needs a meaning the product supports. An empty display name for an anonymous visitor is fine. An empty payment reference hides a bug.

## Offend

- Throw only for a state the business rules say cannot exist. Everything else is an error handled under Defend.
- Prefer a database constraint for a rule about stored data: it holds for every writer, including scripts and other services. The assertion in code is the early warning.
- Assert close to the source, where the bad state is produced rather than where it is used later.
- Assert before irreversible work. An assertion cannot undo a charge or a sent email. Put writes that must succeed together in a transaction so a throw undoes them.
- The message states what must hold, with the identifiers needed to find the record: `"paid order ${order.id} has a payment ID"`.
- Keep assertions few and well placed:
  - the top of a critical function, for state the types cannot express
  - just before an irreversible step
  - a state transition, such as pending to paid
  - wherever a cast or a `!` would otherwise sit
  - the `default` branch of a `switch` over a union, through `unreachable(value: never)`, so a new case fails the build
- Catch once per entry point (route handler, server action, webhook, job). Log the failure under its own event name with an operation ID and return a generic error. Independent work, such as the next job in a batch, carries on.

| Situation | Mode | Do |
| --- | --- | --- |
| A customer asks for minus three items | Defend | Return a controlled error before any side effect. |
| A provider times out after a charge request | Defend | Treat the outcome as unknown and reconcile; a timeout does not prove failure. |
| A paid order has no payment ID | Offend | Assert, and find out how the order got there. |
| A new status reaches a `switch` that should cover every status | Offend | `unreachable` fails the build, then fails loudly at runtime. |

```ts
async function prepareReceipt(orderId: string) {
  const order = await retryTransientRead(() => loadOrder(orderId), { maxAttempts: 3 });

  // Defend: normal outcomes, nothing to prepare yet.
  if (!order) return null;
  if (order.status !== "paid") return null;

  // Offend: a paid order always has a payment ID.
  assert(order.paymentId, `Paid order ${order.id} is missing its payment ID`);

  return { orderId: order.id, paymentId: order.paymentId };
}
```

## Reviewing

On a critical change, read the code and its context for the assumptions it makes without checking them. Suggest each one as a question to the author, for example: "Can a combo ever carry modifiers? If never, assert it." In `elhaam-review`, label it **Should fix**. On any other change, label it **Follow-up** and mark it as optional hardening that makes the system more foolproof. A missing invariant is never a Blocker or a Question on its own; a real defect it would have caught is labelled by that defect's impact.

## Go deeper

- [Offend the bugs and defend the system](https://github.com/itse4elhaam/elhaam.dev/blob/090c459183bb5f4fe3ef8ab59272082a11b11689/content/engineering/offend-the-bugs-and-defend-the-system.md): the long explanation, following one receipt script through both modes.
- [SQLite's assertion philosophy](https://sqlite.org/assert.html): the difference between a proved invariant and a condition that needs handling.
