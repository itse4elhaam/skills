---
name: ux-hill-climb
description: Improve an app's UI/UX against competitor workflows through parallel outcome research, recorded before/after iterations, and fresh independent reviews until the outcome is approved.
---

# UX hill climb

Make the product feel polished in actual use. The user should not have to do the QA for us.

The outcome comes first. Research it, make it checkable, then keep improving until fresh reviewers agree we reached it. A passing test suite does not tell us whether the experience is good.

## 1. Define the outcome

Read the app's instructions, run it, and walk its core tasks. Find the existing tests and the behaviors a UI change could accidentally break. Use disposable data and an isolated session so the user's work stays intact.

Launch parallel research subagents with separate briefs. Cover the current product and the comparison apps, splitting by competitor or user journey as appropriate. Give them the user's goal and raw evidence, not a proposed design to agree with. Ask each for:

- The tasks users should be able to complete and where today's experience gets in their way.
- Specific competitor interactions worth learning from, with dated sources or captured evidence.
- A proposed outcome with observable acceptance criteria, including failure and recovery cases.
- What they could not verify.

Compare equivalent tasks, devices, and states. If the user names paid plans, verify the actual offering and tier. A paid SDK licence and a paid hosted app are different products. Record which one the evidence covers. Use available authorised access; buying access needs its own authorisation. Label public demos and documentation as such. Missing access remains a gap, never an invented hands-on comparison.

Synthesize the research into `outcome.md` in a run folder. Name the audience, journeys, baseline revision, comparison products and tiers, evidence, acceptance criteria, regression constraints, and exclusions. Turn "polished" into concrete judgments about hierarchy, spacing, typography, consistency, discoverability, feedback, keyboard use, and responsive behavior where they affect those journeys. Include task completion and recovery, not just attractive screenshots. Separate useful feature gaps from the UI/UX changes this run is authorised to make.

Each criterion gets an ID and a way to verify it. Record tradeoffs and disagreements. Resolve them against the user's goal and the evidence. Ask only for decisions that materially change scope or require unavailable access; continue independent work meanwhile.

Completion: the parallel research is reconciled into a written outcome that another agent can independently assess. Preserve this version as the target. Revise it only for new evidence or user direction, with the reason recorded. Never lower it to make an implementation pass.

## 2. Capture the baseline

Write a repeatable recipe for every journey in the outcome. Fix the starting data, viewport, theme, input method, and meaningful states. Capture the real app before changing it. Keep a way to reproduce that revision separately from the candidate.

Record the initial regression checks and their failures or skips. Identify what screenshots cannot establish, such as persistence, collaboration, export contents, touch behavior, or recorded output. Verify these through the actual behavior when the outcome depends on them.

Completion: the recipes, baseline recordings, revision, and check results are saved. Before/after evidence can be reproduced without touching the user's live data.

## 3. Improve one coherent part

Choose the largest remaining obstacle to the outcome and make a small, coherent change. Preserve functionality and data contracts unless the user has authorised changing them. Improve colors, layout, copy, controls, motion, and interaction together when the journey needs it. Reuse the app's components and design system where they fit.

Run the affected regression checks and the journey itself. Exercise relevant empty, loading, error, overflow, focus, and recovery states. Test the devices and input methods named in the outcome. Desktop emulation is evidence about emulation, not proof of native touch or hardware behavior.

Completion: the candidate works through the affected journeys, its checks have recorded results, and its remaining gaps are explicit.

## 4. Make the comparison video

Every iteration ends with a watchable comparison video, including rejected iterations. Replay the same recipes against the preceding accepted version and the candidate. Keep the original baseline available so cumulative progress stays visible. Include the original baseline in the final comparison.

Show matching actions side by side, labelled before and after, with revisions. Align by task beats rather than hiding a slower step. Keep text readable. Add short captions that say what changed and why it matters. Use the real app; label simulated services, fixtures, device events, and any states assembled from stills. Never pass off a mockup or screenshot montage as a working interaction.

Use existing recording/rendering tools. Read `document-ux` when its recording or annotation workflow is useful, adapting the renderer to two synchronized views. Retain the raw takes and timestamped edit notes. Verify the exported video by checking its duration, representative frames, and each claimed improvement. Save an ordinary playable file such as `.mp4` and give the user its path after each iteration.

Competitor evidence anchors the judgment, but footage from paid products is included only when actually available. State any evidence gap in the comparison notes.

Completion: the iteration has a verified video, raw evidence, and notes connecting visible changes to outcome IDs. A recording failure leaves this step incomplete.

## 5. Fresh review, then repeat

After every iteration, launch at least two new review subagents in parallel. One judges usability and visual quality against the competitors; another checks whole journeys and regressions. They must be independent of the implementer and the earlier reviewers.

Give each only the user's request, app instructions, the fixed outcome, comparison sources, exact candidate and baseline revisions or diff snapshots, run instructions, checks, and video paths. Use fresh context, with no inherited conversation, implementation rationale, previous verdict, or hint that approval is expected. Let reviewers inspect the running app and original evidence. If they cannot inspect something, they must say so.

Require each reviewer to return:

- `APPROVE`, `REVISE`, or `BLOCKED` for the exact candidate reviewed.
- A pass, fail, or unverified result for every outcome criterion, with evidence.
- Concrete user impact and reproduction steps for each objection.
- Any regression, evidence gap, or reason the video overstates the result.

Approval means all required criteria pass and no blocking regression remains. A high average score, missing reviewer, skipped required check, or unverified criterion cannot substitute for approval. Reconcile conflicting findings through reproduction and evidence, not a vote. Fix valid findings yourself, then run the next iteration with a new video and new reviewers. Any change after review invalidates approval for the affected candidate.

Keep an iteration ledger beside `outcome.md`: revisions, outcome IDs attempted, checks, video, reviewer verdicts, unresolved findings, and the decision to keep or reject the change. Revert only this run's rejected changes, preserving unrelated work.

Continue until every fresh reviewer approves the same final candidate. If access, tools, usage, or an unresolved product decision prevents progress, save the exact blocker and next action. If repeated iterations stop producing measurable progress, diagnose the disagreement and bring the concrete tradeoff to the user. Report an incomplete run honestly; never manufacture approval or quietly weaken the outcome.

Completion: all final reviewers approve, all required checks pass, the final comparison video matches that candidate, and the ledger has no unresolved blocking criteria.

## Delivery

Link the final video, outcome, iteration ledger, and review evidence. Say what improved, what was tested, and the limits of the comparison. Keep every iteration's video available.

Review approval completes the UX loop. Commit, push, merge, deployment, and installation follow the user's authorisation and repository instructions; reviewer approval does not grant them.
