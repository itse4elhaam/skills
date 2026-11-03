# Persistent work ledger

Create durable audit artifacts in a user-approved location inside the working project, using Markdown tables, JSON, or another searchable format. Keep sensitive payloads out. Read this contract before inventorying operations. The report contract consumes this ledger, rather than reconstructing coverage at the end.

## Records

Maintain these linked records with stable IDs. An operation ID survives renamed routes and deduplication through an explicit alias/history entry. Never silently delete a discovered operation or reset its status.

- Audit header: scope, source revision, dirty-file state, exclusions, available runtime/effort and delegation capabilities, isolation evidence, artifact paths, source-discovery state, source-review state and separate deployment-verification state.
- Discovery register: source/method inspected, version, location, raw count, mapped IDs, duplicate/exclusion reasons, reconciliation differences, unresolved leads and dynamic-group bounds. Include custom and native registrations and alternate transports.
- Operations: method/action/resource, effective path and aliases, registration and reachability evidence, caller/role, input/output/effects, branch IDs, shared-control memberships, owner, review status and finding/dependency links.
- Branches and edges: parent operation/group, branch condition or bounded domain, caller-controlled values, effective middleware and order, source to sink to output/effect chain, cross-service producer/consumer IDs, owner and receiving owner, evidence and review status. Cover materially different success, rejection, error, retry and asynchronous flows. Every edge must have an acknowledged receiving assignment or evidence that it terminates within the reviewed scope.
- Controls: operation and branch IDs, each of AUTHN, AUTHZ, INPUT, SINK, OUTPUT, BOUNDS, ABUSE, INTEGRITY and PROTOCOL; applicable subchecks; status; inspected source paths/lines and revision; enforcement chain or failure proof; counterevidence; finding/test/dependency links. Family status rolls up all applicable subchecks, not just the first checked one.
- Shared controls: member IDs, matcher/registration order, exclusions, inherited behavior, bypass checks and evidence that each member actually traverses the control. A group review may be inherited only for the proven common subchecks. Review member-specific inputs, permissions, sinks, effects and outputs separately.
- Findings and tests: stable IDs, affected operations/branches, proof and counterevidence, actual commands/results, isolation and synthetic fixtures, expected/observed behavior, limitations. Proposed tests stay proposed.
- Assignments and dependencies: owner, exact operation/branch/control IDs, revision, accepted output, missing evidence, failed/incomplete delegate work and recovery owner. External blockers need exact missing evidence, safe attempts, exhausted independent work, dependency owner and next step.
- Pending queue/checkpoint: prioritized next actions by ID, unfinished traces, count reconciliation, blockers, completed artifacts and resumption commands. Record which files changed since the checkpoint and invalidate affected evidence before continuing.

`unreviewed` means no substantive tracing; `partial` means any applicable check or branch is unresolved; `reviewed` means all applicable source checks have evidence or supported findings. A parent inherits the least-complete child state. These statuses measure review work, never safety.

Control states are `supported`, `finding`, `unknown`, or `not applicable`, each with evidence or a reason. A family with an unresolved subcheck remains `unknown` even if it also contains a finding. Track runtime observations separately so an unexecuted test does not silently downgrade a proven source conclusion or become a false runtime claim.

## Work loop

1. Register leads, operations, branches and assignments before treating them as covered. Continue discovery as traces reveal additional callers, native handlers, transports or consumers.
2. Trace each assignment and update evidence and next actions continuously. For large inventories, partition by coherent flows or registrations with explicit shared-control and cross-service owners. Keep a parent integration queue.
3. Check delegate evidence against actual source and inspect contradictory claims. Resolve missing branches, boundary mismatches and duplicate ownership. Recover unavailable, failed or partial assignments; do not mark them reviewed on trust.
4. At checkpoints, persist all counts, pending IDs and continuation details. After compaction or a new turn, read the ledger before repeating discovery or writing a conclusion. Continue until the report gate passes or only real external blockers remain.

A large ledger may use shared evidence and separate files; it may not use compressed totals to hide missing per-operation/branch/control work. Exhaustive tracing means accounting for every distinct source-level data-flow/control branch, including a justified bounded symbolic domain for generated cases. It does not promise enumeration of every possible input value or every execution interleaving.
