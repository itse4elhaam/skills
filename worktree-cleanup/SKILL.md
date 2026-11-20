---
name: worktree-cleanup
description: Audit and clean up locally registered Git linked worktrees, including disposable build and dependency directories in retained inactive worktrees.
disable-model-invocation: true
---

# Worktree cleanup

Read [`using-git-worktrees`](../using-git-worktrees/SKILL.md) for Git operations and application bindings. Use the installed sibling skill if working outside the skills repo. An audit or a request to show candidates grants inspection only. Delete only within the scope the user authorized. Apply the same checks whether cleaning one path or several.

## Inventory

1. Run `git worktree list --porcelain -z` in each local repository in scope. Record each registered path, branch or detached HEAD, commit, and lock or prunable reason. Identify the canonical checkout and the checkout running this task. Use Git's registrations across all roots, including application-managed paths.
2. For each accessible linked checkout, inspect `GIT_OPTIONAL_LOCKS=0 git -C "$path" status --porcelain=v1 --untracked-files=all --ignore-submodules=none` and inventory ignored paths separately. A clean status can still hide local env files, caches, and other ignored data. Verify the checked-out commit is merged into the intended destination or independently preserved by a durable ref or backup. For squash or rebase merges, verify the exact checked-out work was included. A PR's merged badge alone does not account for commits added after its reviewed head.
3. Check thread and app bindings, running tasks and processes, and live configuration and symlink references to the checkout or generated directory. Use the owning application's supported tooling to check its bindings. An idle or settled thread may still retain a checkout. Keep any path whose ownership or current use is unclear.
4. Show exact paths with the proposed action and evidence or reason to keep them. Separate whole-worktree removal, generated files in retained checkouts, missing registrations, and paths to leave in place. Use `$show-me` when requested or when a visual would make several candidates easier to compare.

## Apply authorized cleanup

Recheck the relevant status, preservation, bindings, and paths immediately before acting. Skip a candidate if the evidence changed or a check fails.

- **Remove a linked checkout.** Require a clean status, preserved work, a dormant checkout, and confirmation that no thread, app, or live reference retains it. Check ignored content, nested checkouts, and mounts. Proceed only if everything that would be removed is preserved or disposable. Keep locked worktrees, the current checkout, and canonical checkouts. Run `GIT_MASTER=1 git worktree remove -- "$path"` from a retained checkout. If Git refuses, stop and report the reason. Never force removal or delete the checkout directory as a fallback.
- **Reclaim space in a retained inactive checkout.** Inspect only the exact requested directories or confirmed candidates, such as `.next` and `node_modules`. Verify each directory and its contents are generated, reproducible, confined to the linked checkout, and free of tracked files, nested checkouts, or unique local data. Check tracking with `git -C "$path" ls-files -- "$relative_path"`. Check path components for symlinks and shared or mounted locations. Preserve canonical installs, live symlink targets, and any directory still used by an app or task. Delete only the verified directory itself, without following symlink targets. Keep the worktree registration and app binding intact.
- **Prune missing registrations.** When pruning is in scope, confirm each missing checkout is gone and does not belong to an offline or moved volume or a retained app binding. Verify preservation of its work as for a checkout on disk. Run `GIT_MASTER=1 git worktree prune --dry-run --verbose --expire now` first. Run the matching command without `--dry-run` only if every entry in the preview is confirmed eligible and authorized. Git prunes repository-wide.

## Verify

Re-run the registration inventory and check disk paths. Confirm removed worktrees are absent from both, pruned registrations disappeared, and retained checkouts are still registered with their bindings and unrelated files intact. Report what was removed, what was kept, and any failures or unresolved candidates. Report reclaimed space only if measured.
