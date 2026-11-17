---
name: side-ship
description: Use when the user asks to side-ship a separate fix or to fix a problem they spotted in their agent setup mid-task, such as a skill, instructions, or tooling. Send it to a fresh agent to ship through merge and local sync.
---

# Side ship

Give the side task its own agent and its own PR so the current thread can get back to its original task. Invoking this skill authorizes the side task's PR, merge after required checks and reviews, and local sync. Carry over any hold the user set.

## Launch the side task

1. Find the owning repo and the copy the user runs. For agent configuration, trace the active skill, instructions, or setting to its source, following symlinks where present. Write a brief that stands on its own with the desired outcome, repo and base, relevant evidence, constraints and holds, and the live checkout or installation. Use a fresh conversation without the parent transcript or session memory. Keep the project's standing instructions in force.
2. Default to a standalone thread. Use a fresh-context subagent only if the user specifically asks for one and the side task needs further input from them. Relay the subagent's decision or approval request through the parent and send the answer back. In a standalone thread, the worker asks there and continues any independent work.
3. For repo changes, use an isolated worktree in the owning repo. In T3 Code, launch a standalone thread with `t3_thread_launch` and a worktree `workspaceStrategy`. Use `delegate_task` with worktree isolation for the subagent path. Branch independent work from the remote default, or the local default for a repo without a remote. Honor a requested base and use the required local base when the work depends on unpublished commits. If the selected launch path cannot reach the owning repo, surface that before starting work in the wrong checkout.
4. Give the worker the steps below in its brief. After a successful standalone launch, share the host-provided thread link once and immediately return to the original task. The side thread owns all progress, decisions, verification, and follow-up. Keep the side task out of the original thread's plan. Do not wait, poll, watch its PR, or check back after launch. On the explicitly requested subagent path, relay only the user's needed input.

## Worker's brief

1. Implement and verify the requested change. Read the target project's instructions. Commit and push only the side task's changes. Open a separate PR for them and link it immediately in the working thread using the host's PR tool. If the change has no PR-capable repo, report that limit and finish the authorized local work.
2. Use `$show-me` in the working thread before merging. Show the behavior that changed and how the user will experience it. In T3, preview and render the visual inline. If the reviewed change moves materially, update the walkthrough. For a subagent, use its visible child thread. If it cannot render there, send the visual to the parent to render before merge.
3. Follow required checks and reviews and address findings. Read `~/.agents/skills/conclude-thread/SKILL.md` and follow its finish and settle procedure using the authorization in the brief. Follow the host's PR watcher rules in the side thread. If the subagent path reaches a capability it lacks, report the specific blocker in the side task instead of making the original thread monitor it.
4. Confirm the PR is merged and bring the merged base into the actual local checkout and refs. Preserve unrelated edits and the parent worktree. Run any install steps the change requires and verify the active copy. For a skill in Elhaam's skills repo, ensure its link in `~/.agents/skills/` resolves to the live copy.
5. Report the PR, merge SHA, local ref or install verified, and any remaining blocker. Use the host's settle tool on the side thread after the receipt and completed sync. If the host settles automatically on merge, still finish and verify the sync. An open PR, pending local sync, or unresolved user decision is still in progress.
