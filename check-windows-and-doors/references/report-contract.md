# Report contract

Read and maintain [the work ledger](work-ledger.md). Deliver findings and reconciled coverage together only after applying the completion gate below. Keep the opening readable without knowing the repository. Put detailed evidence and the full inventory after the main conclusions.

## Scope

Record repository, revision and dirty state, included apps and operation families, explicit exclusions, evidence available, and test environment. State whether discovery is complete within that scope. If dynamic registration, missing packages, or unavailable configuration prevents enumeration, name the gap and report counts as known operations only.

## Findings

For each supported finding include:

- Stable finding ID, severity, confidence, and affected operation IDs.
- A title naming the consequence, followed by complete sentences describing the caller, triggering input or action, prerequisites, violated rule, and impact.
- Source paths and line numbers, the enforcement or failure path, and relevant local test results. Mark evidence as static, locally reproduced, or both.
- Counterevidence considered and material assumptions or limits.
- The smallest fix and a regression case that rejects the bad request while preserving legitimate behavior.

Choose severity from credible impact and exploit prerequisites. Critical means broad system compromise or catastrophic data/control loss with a credible reachable path. High covers serious unauthorized access, privilege escalation, or material integrity/availability loss. Medium covers constrained but meaningful harm. Low covers limited harm. Explain the rating; do not infer severity from a keyword or assign a numeric score without a full method.

Use high, medium, or low confidence independently. Put unproved defect hypotheses under verification gaps, with the missing evidence and next check. Do not bury an unverified premise in a confirmed finding.

Example of presentation only:

> A signed-in customer can download another customer's invoice by changing the invoice ID. The route checks the session, but the query selects by invoice ID without checking ownership. Restrict the query to invoices the caller is allowed to read. Add a local test where customer A requests customer B's invoice and is denied, while B can still download it.

Attach real paths and evidence when reporting an actual finding. Do not reuse the example as a finding.

## Operation inventory

Keep one row per operation and distinguish concrete methods, actions, procedures, or message types. For direct data access, distinguish resource and allowed action. Record unknown generated groups separately from enumerated operations.

| ID | Operation and source | Intended caller | Inputs and outputs | Effects | Reachability evidence | Review status | Findings/gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |

Review status must be exactly one of:

- `reviewed`: every applicable source control and branch has evidence or a supported finding; no unresolved applicable source check remains.
- `partial`: some source checks are done, but at least one applicable source control, branch or policy remains unknown.
- `unreviewed`: no substantive control tracing completed.

A reviewed operation can contain defects. Review status measures work completed, not safety. Record inspected internal helpers separately with evidence that they are not independently exposed; do not pad the operation totals with helpers.

## Control ledger

For each operation, cover AUTHN, AUTHZ, INPUT, SINK, OUTPUT, BOUNDS, ABUSE, INTEGRITY, and PROTOCOL as defined in the control reference. Use one of `supported`, `finding`, `unknown`, or `not applicable` for each family. Link an evidence note, finding ID, or reason to every status. If a family has both a finding and unresolved checks, mark it unknown, retain the finding link, and describe both.

Evidence may be shared, but list the affected operations and verify the shared control applies to each. Separate source-supported controls from runtime-tested controls. Keep deployment/runtime unknowns in their own linked verification records; a source audit does not establish deployed state. If missing configuration also prevents a source conclusion, keep that specific source check unknown and exhaust the rest of its source trace.

Report these exact totals over the known inventory:

`known operations = reviewed + partial + unreviewed`

Also give the number of operations with supported findings and the number exercised locally. These are overlapping subsets, not additional status buckets. Count unique root-cause findings separately from affected operations. If giving a percentage, disclose its denominator and never present discovery-incomplete coverage as a percentage of the whole system.

## Local test record and gaps

List actual commands, isolation evidence, synthetic actors/data, expected and observed results, and whether the real control executed. Label tests passed, failed, blocked, or not run. Never convert a proposed test into a completed check.

For each remaining gap, state the affected operations, why it remains unknown, the evidence needed, and the next bounded local or read-only check. Distinguish deployment verification that would need separately authorized access.

Finish with the first remediation or verification step that follows from the evidence. A zero-findings audit must still include coverage and limitations.

## Hard completion gate

Record each gate result with evidence links. Before passing, compare the final revision and dirty files with the versions recorded in the ledger. Invalidate stale evidence and retrace affected operations, branches, controls and registration dependencies, including callers/consumers, until every completion claim matches the final source state:

1. Discovery sources reconcile to the full in-scope inventory. Custom, native/framework/plugin, dynamic and alternate paths have no unexplained omissions. Every dynamic group has an inspected generator, a proven domain bound and accounted control/effect branches, or an exact blocker.
2. Every operation and branch has an owner and a completed trace across all nine control families, including applicable subchecks. Shared controls have proven membership and ordering. Cross-service edges and delegate outputs have been integrated and checked.
3. Known operations = reviewed + partial + unreviewed. Reconcile the same statuses for branches, groups, edges and control subchecks, and list pending IDs rather than totals alone. Findings and local-test subsets must match their linked records.
4. There are zero unreviewed pathways and zero avoidably partial checks. Every candidate finding has been challenged with counterevidence and every reported test has an actual record.

Only passing all four gates permits **source review complete**. Report **deployment/runtime verification** independently as verified within named local conditions, partial, or not performed. Neither state is a guarantee of security.

If a real external dependency prevents a source check, label the audit **incomplete, externally blocked** and enumerate the exact flow/control, missing evidence, safe attempts, exhausted independent source work, dependency owner and next action. Any ordinary unfinished tracing requires continued work, not this exception. A user stop or enforced runtime/context interruption permits an **incomplete checkpoint** with durable resumption details, never a completion claim. A generic deployment unknown cannot justify leaving source branches unreviewed.

Regression example: 1,465 discovered operations, 982 partial, 483 unreviewed, shared authentication reviewed and two supported findings fails the gate. It requires continued tracing and reconciled discovery, even if the findings are severe. A later inventory with different native/custom totals is a reconciliation task, not evidence that either audit is finished.
