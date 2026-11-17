---
name: council
description: Convene available agents to independently challenge a plan, implementation, or audit when the user asks for Council.
---

# Council

Adapted from [Theo Browne's Council](https://github.com/t3dotgg/tstack/blob/11e37a74d0a6868c121cd0910ab2b3bd9873b92a/skills/council/SKILL.md) under the [MIT License](LICENSE).

See [Theo's Council video notes](references/theo-council-video.md) for the score target, review brief, and stopping rule.

## Choose reviewers from the current host

Before a code audit, address known in-scope issues and outstanding PR feedback and run the relevant checks. Skip fixes to work the user wants to discard. Keep read-only requests read-only.

- In T3 Code, call `orchestrator_capabilities` before the first delegation in the thread. Use its current catalog for this run and follow host rules for refreshing it. A catalog entry alone is insufficient. Require `canRunChildTask` and, for a cross-provider launch, `canRunCrossProviderChildTask`. Exclude disabled or unavailable models and honor provider constraints, including quota guards.
- Use `delegate_task` with the discovered provider instance and model. Choose high reasoning effort if the entry advertises it. Use the default service tier and keep fast mode off. Use only supported option IDs and values in `target.options`. Follow the host's wait or continuation instructions and respect its concurrency limits.
- Outside T3 Code, use the current host's advertised subagent capabilities and delegation tools. Apply the same eligibility and selection rules with the information the host exposes.

Honor the user's named members, count, and non-blocking preferences. Report each named member that cannot run and leave that seat empty. By default, select one reviewer from every eligible underlying model vendor. Count accounts and wrappers that serve the same vendor together. A reviewer must be able to inspect the snapshot and challenge the work. An adversarial label is optional. With only a requested count, use it as a maximum and prefer host-recommended reviewers, then catalog order. Run with fewer if the catalog cannot fill the count. Include at most one reviewer with an unknown vendor in the default selection, after verified vendors and within any requested count.

Prefer the latest runnable flagship from each selected vendor, including the lead's model if it is the best available reviewer. If the host lists several comparable flagships, use its preferred model or the first eligible flagship in catalog order. If the catalog is abbreviated, use an allowed host lookup to resolve a named member or find a better default. Use the eligible models you can verify when no further lookup is available. If none can run, report that Council could not convene and label any in-scope self-review separately. Handle failed launches under the host's retry rules and report any missing coverage.

## Run independent reviews

Give reviewers the original request, exact revision or snapshot, relevant checks, and scope. Use the same snapshot for the whole round. Launch independent reviews in parallel when supported and use batches if the host limits concurrent reviewers. Give each reviewer a read-only brief to challenge the work against the user's intent and look for counterexamples, regressions, or weak evidence. Let reviewers run relevant checks when authorized and when the checks preserve the shared snapshot. Ask for severity, concrete evidence such as a file and line or check result, and what would resolve each finding. Ask for an explicit verdict and a score out of 10 for code reviews or whenever the user sets a score target. Use the user's stated criterion for scoring. Withhold peer verdicts and scores during the initial review.

As results arrive, verify findings against the work and decide what needs fixing. Keep a shared checkout stable for everyone reviewing it. Give non-blocking reviewers an isolated snapshot before launching them. If you cannot provide one, report the missing coverage. Treat late results as feedback outside the completed round.

Fix verified, in-scope findings when authorized, run the relevant checks again, and start a fresh review on the updated snapshot. Reinvite the original reviewers where available, with the fixes and remaining objections. In T3 Code, use a new `delegate_task` for each re-review.

Interpret `Council N` as a minimum score of N/10, where N is from 1 to 10. For example, `Council 9.5` sets a target of 9.5/10. A request for a council of a given size sets the reviewer count. The target is met when at least one blocking reviewer scores the current revision and every blocking reviewer scores it at or above the target. Missing scores or unavailable blocking reviewers leave the target unverified. Without a target, use the blocking reviewers' verdicts.

End the review loop when the target is met or, without a target, when blocking reviewers accept the revision. Also stop at a user-set round limit or when a round yields no verified in-scope fix that could make progress. Report the last scores, blockers, and unmet target, if any. Keep the review within the original scope and follow the user's merge instructions.

## Report the evidence

State the revision reviewed, who completed each round, missing coverage, verified findings, and unresolved objections. Identify reviewers whose vendor is unknown and exclude them from the count of distinct vendors. Count each completed review pass as one round. When scores were requested, record the scores actually returned by each reviewer for each completed round. Use “no score” only if a completed review omitted a score. Record missing reviews in the coverage note and omit late non-blocking scores. Claim agreement only when multiple independent reviewers explicitly agree on the current revision. A single review has its own verdict.

When authorized to edit the PR, put the results in a `## Council review` section of the PR description, before the model and harness line if present. Include the round count. When scores were requested and at least one reviewer completed a round, use one table row per reviewer who completed a round and one column per completed round. Use `not run` for a skipped round and `incomplete` for a review that started and did not finish in time. Use the reply when there is no authorized PR edit.
