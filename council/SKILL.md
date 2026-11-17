---
name: council
description: Convene independent adversarial agents to challenge a plan, implementation, or audit when the user asks for Council.
---

# Council

Adapted from [Theo Browne's Council](https://github.com/t3dotgg/tstack/blob/11e37a74d0a6868c121cd0910ab2b3bd9873b92a/skills/council/SKILL.md) under the [MIT License](LICENSE).

## Choose reviewers from the current host

Before a code audit, address known in-scope issues and outstanding PR feedback and run the relevant checks. Skip fixes to work the user wants to discard. Keep read-only requests read-only.

- In T3 Code, call `orchestrator_capabilities` before the first delegation in the thread. Use its current catalog for this run and follow host rules for refreshing it. A catalog entry alone is insufficient. Require `canRunChildTask` and, for a cross-provider launch, `canRunCrossProviderChildTask`. Exclude disabled or unavailable models and honor provider constraints, including quota guards.
- Use `delegate_task` with the discovered provider instance and model. Choose high reasoning effort if the entry advertises it. Use the default service tier and keep fast mode off. Use only supported option IDs and values in `target.options`. Follow the host's wait or continuation instructions and respect its concurrency limits.
- Outside T3 Code, use the current host's advertised subagent capabilities and delegation tools. Apply the same eligibility and selection rules with the information the host exposes.

Honor the user's named members, count, and non-blocking preferences. Report each named member that cannot run and leave that seat empty. By default, select up to three reviewers, one per underlying model vendor. Count accounts and wrappers that serve the same vendor together. If a default seat is still open, at most one eligible reviewer with an unknown vendor can fill it.

Prefer the latest runnable flagship from each selected vendor, using a different model from the lead's when a comparable one is available. If the catalog is abbreviated, use an allowed host lookup to resolve a named member or find a better default. Use the eligible models you can verify when no further lookup is available. If fewer qualify, run with the available reviewers. If none can run, report that Council could not convene and label any in-scope self-review separately. Handle failed launches under the host's retry rules and report any missing coverage.

## Run independent reviews

Give reviewers the original request, exact revision or snapshot, relevant checks, and scope. Use the same snapshot for the whole round. Launch independent reviews in parallel when supported. Give each reviewer a read-only brief to challenge the work against the user's intent and look for counterexamples, regressions, or weak evidence. Ask for severity, concrete evidence such as a file and line or check result, and what would resolve each finding. Ask for an explicit verdict and a score out of 10 for code reviews. Withhold peer verdicts and scores during the initial review.

As results arrive, verify findings against the work and decide what needs fixing. Keep a shared checkout stable for everyone reviewing it. Give non-blocking reviewers an isolated snapshot before launching them. If you cannot provide one, report the missing coverage. Treat late results as feedback outside the completed round.

Fix verified, in-scope findings when authorized, run the relevant checks again, and start a fresh review on the updated snapshot. Reinvite the original reviewers where available, with the fixes and remaining objections. In T3 Code, use a new `delegate_task` for each re-review. Repeat until blocking reviewers accept the current revision or a remaining objection, unavailable reviewer, or user constraint prevents closure. Surface unresolved findings and disagreements without broadening scope to chase scores.

## Report the evidence

State the revision reviewed, who completed each round, missing coverage, verified findings, and unresolved objections. Identify reviewers whose vendor is unknown and exclude them from the count of distinct vendors. Count each completed review pass as one round. For code reviews, record the scores actually returned by each reviewer for each completed round. Use “no score” only if a completed review omitted a score. Record missing reviews in the coverage note and omit late non-blocking scores. Claim agreement only when multiple independent reviewers explicitly agree on the current revision. A single review has its own verdict.

When authorized to edit the PR, put the results in a `## Council review` section of the PR description, before the model and harness line if present. Include the round count. For code reviews, use one table row per reviewer who completed a round and one column per completed round. Use `not run` for a skipped round and `incomplete` for a review that started and did not finish in time. If nobody completed a code review, report the coverage without a score table. Use the reply when there is no authorized PR edit.
