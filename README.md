<p align="center"><img src="assets/skills-logo.svg" width="128" alt="skills logo"></p>

# Skills

AI agent skills for code review, Git workflows, documentation, and structured data access. These skills are designed for [OpenCode](https://opencode.ai) and other AI coding agents that support the skills specification.

> **Installed automatically** by [`dev-setup/runs/skills.sh`](https://github.com/itse4elhaam/dotfiles/blob/main/dev-setup/runs/skills.sh) in [itse4elhaam/dotfiles](https://github.com/itse4elhaam/dotfiles) — it clones this repo to `~/workspace/coding/skills` and symlinks each skill into `~/.agents/skills/`.

## Skills

| Skill | Description |
|---|---|
| **council** | Convene available reviewers to independently challenge the work, verify findings, and re-review fixes. |
| **check-windows-and-doors** | Audit exposed APIs, server actions, RPCs, webhooks, and direct data access. Trace security controls, use isolated local tests, and report evidence-backed findings with operation-level coverage. |
| **elhaam-review** | Reviews code the way Elhaam does: every hunk earns its place, fits the codebase, reads like English, treats server exports as public endpoints, carries tests that earn their place, and fixes the cause once. Writes an HTML report and inline comments in his voice. |
| **static-pr-dry-run** | Bounded static pre-ship review of a PR or diff. Builds a traceable obligation ledger, source-traces each case, reports exact ledger counts, exposes runtime gaps, and returns `SHIP`, `SHIP AFTER CHECKS`, or `DO NOT SHIP`. |
| **elhaam-voice** | Write or rewrite text in Elhaam's personal voice — warm, direct, thoughtful, commercially aware, leading with a clear position. Preserves conviction and user-authored language while removing generic AI polish and corporate fog. Model-invoked for first-person writing; never for code or tech docs. |
| **copywriting** | Write website and product copy (headlines, sublines, CTAs, bios, testimonials, microcopy) from a fact sheet, as options across distinct angles, then pick one with reasons. Includes the warm-turn rule for playful lines that stay true. Pairs with unslop; first-person writing goes to elhaam-voice. |
| **pr-review-dossier** | Read-only investigation of GitHub PR review feedback. Fetches review threads via GraphQL and produces an evidence-backed HTML dossier with a recommended decision or way ahead. |
| **posting-pr-review-comments** | Publish inline review comments to a GitHub PR as a single batched review. Write-side counterpart to read-only review skills. OpenCode config provides defense-in-depth via `ask` gates on `gh api` and `gh pr` mutations — see [opencode.json](https://github.com/itse4elhaam/dotfiles/blob/main/.config/opencode/opencode.json) `permission.bash`. The current-turn user directive is the primary authorization, not the permission prompt. |
| **local-change-review** | Review uncommitted local changes by grouping related hunks into small, intentional commits. |
| **using-git-worktrees** | Create or move Git worktrees only after the user confirms the location. Defaults to `/home/elhaam/workspace/coding/bluum/worktrees/` and preserves uncommitted changes during moves. |
| **conflict-rebase-resolution** | Merge or rebase by gathering a holistic view of conflicts, then resolving them safely. |
| **readable-html-dossier** | Visual-first HTML reports: the answer up front, a diagram or table for every point, captions instead of essays, evidence one click away. |
| **show-me** | Explain with a focused HTML diagram rendered inline in T3 Code and a brief takeaway. |
| **html-feedback** | Keep feedback on HTML artifacts inside the document, on a path the current agent is verified to read. |
| **html-read-aloud** | Add in-browser narration and synchronized scrolling to standalone HTML documents via the Web Speech API — block-by-block reading, active-block highlighting, voice/rate controls, progress persistence. Works from `file://` with no server, framework, or external dependency. Composes with readable-html-dossier. |
| **understand-code-like-an-owner** | Explain code to someone who did not write it — an ownership-grade data-flow narrative anchored on a small dataset traced from the user's eyes into the app, in the reader's product language. Phase A of bug-explainer; standalone for onboarding and code walkthroughs. |
| **bug-explainer** | Explain a bug found by an agent to the human who owns the product but did not write the code — symptom-first, plain-language report anchored on a small dataset traced from the user's eyes to where the issue is, with impact & severity proposal, mechanism vs trigger, fix end state, and evidence appendix. |
| **document-ux** | Compare actual UI against the selected design with matched before/after screenshots, or record and annotate a short interaction video when behavior must be shown. |
| **diagnosing-bugs** | Diagnose bugs through a symptom-specific feedback loop, with a separate incident-evidence route for intermittent failures, recovery and unverified causes. |
| **missed-asks** | Read-only audit of linked conversations against delivered work. Reports only forgotten, partial or unverified requests, preserving corrections and explicit deferrals. |
| **thread-title** | Check the current title on each user prompt and update it when the active work changes. |
| **logging-and-monitoring** | Leave durable, bounded diagnostic evidence when implementing runtime behavior so an agent can trace a later failure without reproducing it. |
| **implementation-ownership** | Decision-oriented ownership review of an agent-implemented change: the problem it solves, why this approach, its assumptions, failure modes and detection signals, and the smallest safe rollback — ending in one approval recommendation at a named understanding level. The approval review; complements understand-code-like-an-owner's explanation. |
| **doc-map** | Maintain a branch-aware DOC_MAP.html registry with document summaries, reading metadata, and persistent read status. |
| **github-graphql-first** | Fetch structured GitHub data — PRs, reviews, review threads, comments, project items, timelines — using `gh api graphql`. |
| **linear-issue-recon** | Pull full context from a Linear issue (description, comments, linked issues and PRs), explore the codebase, and produce an HTML dossier with a way-ahead recommendation. |
| **upload-to-drive** | Upload to Google Drive with `rclone` instead of the MCP, and free local space by deleting only copies verified on Drive, after the user confirms. |
| **boxes-dev** | Run work on boxes.dev cloud devboxes with the `dvb` CLI: create, stage files, exec, agent threads, sleep/destroy hygiene, and a box-hour budget guard. Credentials stay off the boxes. |
| **subagent-retry** | Recover stuck or incomplete subagent work — extract output, assess completeness, then finish the remainder or fire a follow-up agent. User-invoked. |
| **ship-via-worktree-pr** | Hand a task to a subagent in an isolated worktree that ships it as a PR and merges it when the user has authorized merging, then fast-forward local refs and bring the merged change into the current branch. |

## Installing from this repo

Install individual skills via `npx skills`:

```bash
npx skills add itse4elhaam/skills@elhaam-review --global --all --yes
npx skills add itse4elhaam/skills@local-change-review --global --all --yes
```

Or install all skills at once:

```bash
npx skills add itse4elhaam/skills --global --all --yes
```

## Adding a new skill

1. Create a new directory: `mkdir -p <skill-name>`
2. Add `SKILL.md` with [frontmatter](https://github.com/mattpocock/skills). Model-invoked skills keep a trigger-oriented `description`. On runtimes that support user-only invocation, user-invoked skills set `disable-model-invocation: true`; OpenCode ignores that extension, so use its skill permissions when the distinction must be enforced there.
3. Commit the skill. The pre-commit hook symlinks each top-level directory containing `SKILL.md` into `~/.agents/skills/` if that name is missing. Existing entries, including dangling symlinks, are preserved.

Enable the hook once per clone:

```bash
git config --local core.hooksPath .githooks
```

To link a skill before committing: `ln -s "$PWD/<skill-name>" ~/.agents/skills/<skill-name>`.
