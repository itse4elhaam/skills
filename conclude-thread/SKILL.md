---
name: conclude-thread
description: Finish the thread's work end to end (commit, push, merge, sync the live copy), give a receipt, then settle the thread
disable-model-invocation: true
---

Finish the thread's work so the user can mentally forget that this thread existed.

Invoking this skill is the authorization to finish the thread's own work end to end: commit what is uncommitted, push, merge the thread's open PRs, run the agreed deployment or install steps, and bring the live copy up to date by pulling the merged default branch into the checkout the user actually runs from, with any unrelated local changes carried through intact. The scope is the work this thread started or was asked to do.

A hold the user stated in the thread and has not lifted still stands: "don't merge", "draft only", a named finalizer, a release condition. Finish everything up to the hold and name it in the receipt.

Before closing, reconcile the current requests against what was delivered. Keep corrections and superseded requests straight. Distinguish implemented, verified, merged, installed and actually running; one does not prove the next. Reuse the task list rather than creating another report.

Run the relevant final checks before merging, and verify the active revision afterwards. If a consequential decision remains unresolved, name it and finish the independent work.

Give a short receipt: what the user can now do, the material proof, and any remaining gap or hold. Passing tests alone is not proof that the requested outcome is active.

Then self-settle the thread using the host's thread tool. A read-only investigation can finish and settle without inventing merge or deployment work.
