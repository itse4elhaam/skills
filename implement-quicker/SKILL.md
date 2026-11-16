---
name: implement-quicker
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

For multiple requests, keep one compact task list with the requested outcome, acceptance condition and current disposition. Update it when the user corrects, replaces or defers something. Do not let a request disappear between delegates or threads.

Use /tdd where possible, at pre-agreed seams.

Use logging-and-monitoring when changing runtime behavior. Leave durable evidence of the changed flow so a later agent can investigate a failure without reproducing it.

Run typechecking regularly, single test files regularly, and the quickest validation suite at the end.

Only run the relevant tests to your changes.

Donot perform code-review unless asked for

Before delivery, reconcile every current request against the implementation and its observable result. Check returned delegate evidence and interactions yourself; a completion message is not proof. Distinguish code written from the revision actually installed and running.

Present the relevant diff and a short completion receipt. Finish delivery already authorized by the user. Wait only for an unresolved approval or decision; preserve explicit draft, review and release conditions.
