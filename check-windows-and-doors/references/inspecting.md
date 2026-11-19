# Inspecting a section

Every opening in the section gets one verdict. The section ends when the last opening has one.

## The verdict

An opening is `closed` when the code proves all four parts:

1. **Reach.** Only the intended callers get in.
2. **Own data.** A caller reads and changes only what belongs to them: their records, their tenant, the fields they may see and set.
3. **Values.** Nothing the caller sends changes what they are entitled to. They cannot set a price, role, owner or status, and their input cannot alter a query, command, path or outbound request.
4. **Repetition.** Calling it again, in bulk or at the same moment, harms nobody and costs nothing that matters.

A `closed` opening can still carry a "worth hardening" line. A missing cap or weak default with no break-in story leaves the verdict `closed` and adds that line.

An opening is `open` when one part fails and you can write the break-in story below. That is a finding.

An opening is `can't tell` when the proof depends on something outside the repository, or when a part fails on its face and one missing fact decides whether the story works. Name the missing evidence and where it would be found.

Read the code before choosing `can't tell`. It is for evidence that is absent, such as a private package or deployed configuration. Unread source is unfinished work.

### What counts as proof

- The file and line of the lock, and the path showing this opening passes through it. A helper's name, an import, or a comment proves nothing until you have seen the call and its place in the order of execution.
- For shared locks, the matcher or registration that puts this opening behind them. Prove a shared lock once in the frame, then confirm membership for each opening.
- For direct data access, the grants and policies for each action, and the role the client connects with. A service-role connection bypasses row-level policies.
- The intended rule comes from the product: the roles on the map, the UI, the docs. When the rule itself is unclear, the verdict is `can't tell` and the note asks the user the question.

Follow each opening into the queries, jobs and outbound calls it triggers, and into its error, retry and concurrent paths when those run different checks.

## Where to look

| Part | Check |
| --- | --- |
| Reach | Session or token verified on the server, including expiry and signature. Identity headers trusted only from a verified proxy. Admin role enforced on the server. Webhook signature verified over the raw body before any effect. For cookie sessions, a cross-site request cannot trigger a change. |
| Own data | The query is restricted to the caller's records or tenant, with the ID taken from the verified identity. Nested objects and bulk IDs are each checked. The response selects permitted fields only, including in errors, exports, caches, signed links and subscriptions. |
| Values | Runtime validation runs before use and rejects unknown fields. Writable fields are listed explicitly. SQL values are parameterized and dynamic identifiers come from a fixed list. Caller-supplied URLs cannot reach internal addresses. File names and paths are generated or confined. State changes follow allowed transitions. |
| Repetition | Codes, resets, invites and paid calls are limited per account and per target. A one-time token is consumed once, even under concurrent requests. A webhook or payment retry applies once. Lists and exports have a server-side cap. |

## The break-in story

Write it from the attacker's side of the screen, in four short lines:

- **Who.** A stranger, a signed-in user, or an agent working for either.
- **What they must know or guess.** A serial ID is guessable by counting. A random ID has to leak first, so say where it could leak from, such as a shared link, an email, a log or a referrer. The missing check is a finding either way, and the guess decides its tier.
- **The steps.** What they send, in order.
- **What they walk away with.**

Two rules decide how much the story is worth:

- Being hard to find protects nothing. An unlinked URL, an action only one page imports, and a field the UI never sends are all reachable by an agent that reads the bundle.
- Being hard to guess does count. A random ID that other users never see makes the story harder, and the finding's tier says so.

A missing limit is a finding only when it has a story. Sending one-time codes with no wait lets anyone flood a victim's phone, run up the SMS bill, or keep guessing codes. An uncapped list of public posts has no story and goes under "worth hardening".

## Running it

Static proof is enough for a verdict. Run the application when one request would settle whether the story works, and only inside the boundaries in the skill: this machine, a proven isolated environment, made-up data. Pair the attacking request with the legitimate one, so the note shows the stranger refused and the owner served. Record the command, what you expected, and what happened.

When static reading leaves the story unsettled and no isolated environment exists, the verdict is `can't tell` and the missing evidence is a run in an isolated environment.

## Avoid false alarms

- A lock can live in middleware, a wrapper, a parser or a database policy. Look for it there before reporting it missing.
- Public content is meant to be readable. Establish the intended rule before calling a read a leak.
- Raw SQL is not injection, and parameterized values do not make a dynamic table or column name safe. Trace the value.
- A limiter that lives in one process may not hold across several. Say what you assume about deployment.
- A migration file shows what was written, not what a live database has applied. Record that as `can't tell` for the deployed state and keep the source verdict.
