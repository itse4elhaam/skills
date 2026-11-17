---
name: ship-via-worktree-pr
description: Ship a task as a PR from a subagent in its own worktree, then sync the local checkout with the merged result. Use when the user says "do this in a PR", "separate worktree, subagent, get it merged", "ship this as a PR and update local", or "fire it off in a subagent".
---

# Ship via worktree PR

The parent scopes and hands off the work, a child ships it as a PR from an isolated worktree, and the parent brings the merged result back into the local checkout. You run this as the parent.

## 1. Write the brief

The child sees nothing but the brief, so it has to stand alone. Fill in every field:

```text
Goal: <outcome, in the user's words>
Repo / base: <repo path or project>, branch from <origin default branch>
Areas: <files and dirs to change>
Out of scope: <files, uncommitted parent work, anything to leave as is>
End state: <observable result that means done>
Verify: <exact commands that must pass>
Commit: <repo commit style + required attribution trailer>
PR: body via the pr skill; trailer <required PR attribution>
Merge: <"squash-merge authorized by the user" | "stop at PR ready">
Report: last line "PR <url>, head <sha>, merged <yes/no>, merge commit <sha|none>"
```

Set `Merge` to authorized only if the user explicitly approved merging in this conversation. Anything else, including approval given for an earlier task, means `stop at PR ready`.

Done when every field is filled in and a reader with no context could start work from the brief alone.

## 2. Launch the child

Start the child in a fresh worktree branched from the remote default branch, so the parent's uncommitted work stays out of it:

- **T3 Code, same project:** `delegate_task` with `isolation: "worktree"`.
- **T3 Code, another repo:** `delegate_task` can't create a worktree in another project, so open a worktree thread there with `t3_thread_launch` (`workspaceStrategy`, `startFromOrigin: true`).
- **Elsewhere:** the Agent tool with worktree isolation, or create one with using-git-worktrees.

For independent tasks, launch the children together, one worktree and one brief each. If a child stalls or returns partial work, recover with subagent-retry.

Done when each child's final report includes its status line.

## 3. Child: implement and ship

The child works through these steps in order:

1. Implement the change and run every `Verify` command until each one passes.
2. Commit using the brief's style and trailer, push, and open the PR. In T3 Code, link the PR with `link_pull_request` as the very next call.
3. Check CI once with `gh pr checks`. Report a failing check rather than merging past it.
4. If `Merge` is authorized, squash-merge. Run `gh pr merge` without `--delete-branch`: from a worktree, gh tries to check out the default branch, which fails while another worktree has it checked out. Delete the remote branch afterwards with `git push origin --delete <branch>`.
5. Read the outcome from GitHub instead of trusting gh's exit output. Use github-graphql-first to fetch `state`, `headRefOid` and `mergeCommit.oid`.

Done when the PR exists and its state matches `Merge`.

## 4. Parent: sync local

After the PR is merged:

1. Run `git fetch origin`, then fast-forward the local default branch:
   - If no worktree has it checked out: `git fetch origin main:main`.
   - If a worktree has it checked out: run `git pull --ff-only` in that worktree. Git refuses the `main:main` form there.
   - If the fast-forward fails, stop and report the divergence.
2. If you're on a feature branch, bring the merge in with the repo's usual merge or rebase. Set uncommitted changes aside with a temporary WIP commit. If you must stash, push a tagged entry, apply it by SHA, then drop it. The stash stack is shared across worktrees. Resolve conflicts with resolving-merge-conflicts.
3. Rerun verification on the parent branch.
4. Remove the child's worktree and local branch per the Cleanup section of using-git-worktrees. Remove an app-managed worktree with that app's own tooling.

Done when the local default branch equals `origin/<default>`, the parent branch contains the merge commit, verification passes, and your uncommitted changes are back as they were.

## 5. Report

Tell the user what merged (with the PR link), what changed locally (refs fast-forwarded, branch merged or rebased, worktrees removed), and anything left: failing checks, an unmerged PR, conflicts you resolved, skipped cleanup.
