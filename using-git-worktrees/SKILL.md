---
name: using-git-worktrees
description: Create, relocate, and clean up Git worktrees using the global ~/.worktrees default while preserving checkout state and application bindings.
---

# Using Git worktrees

## Location

The user's standing default is `$HOME/.worktrees`. Use it without asking,
including when older worktrees live elsewhere. An explicit path or root in the
current request overrides that default. Do not reopen the location debate for
each task.

Use `<repository>.<branch>` under that root. Derive the repository name from
the canonical checkout and replace `/` in the branch name with `-`.

```text
repository: bluum-medusa
branch: fix/klaviyo-checkout-links
path: /home/elhaam/.worktrees/bluum-medusa.fix-klaviyo-checkout-links
```

If an automatically chosen name is occupied, choose an unused numeric suffix.
Inspect and report collisions at explicitly requested paths rather than
replacing another checkout. Keep permanent checkouts, shared configuration,
and live symlink targets outside this temporary root.

## Create or move

Prefix Git commands with `GIT_MASTER=1` for the local Git hooks. A missing
optional Git helper skill does not block ordinary worktree commands.

Before changing locations, record `git worktree list --porcelain` and the
checkout's `git status --short --branch`. Independent work normally starts
from the remote default branch; dependent work keeps its required local base.

```bash
mkdir -p "$HOME/.worktrees"
GIT_MASTER=1 git worktree add <destination> -b <branch> <base>
GIT_MASTER=1 git worktree move <source> <destination>
```

Use `git worktree move`, not a filesystem move. Preserve staged, unstaged,
and untracked files. A policy change alone does not relocate existing worktrees.

T3 Code and other applications can bind threads, processes, or cached paths to
their own worktrees. Use their supported tooling for managed work. Move a
managed checkout only when its application bindings can also be updated.
Keep checkouts owned by other active tasks in place.

Afterward, verify Git's worktree list and destination status against the
recorded state. Report the chosen path and any preserved changes.

## Cleanup

When the task includes cleanup, remove a worktree only after its work is merged
or otherwise preserved, its status is clean, and it has no active owner or live
configuration references. Use `GIT_MASTER=1 git worktree remove <path>`.

Keep dirty, active, locked, unmerged, and application-managed checkouts until
those conditions are resolved. Do not force removal or delete a whole worktree
root to tidy it up. Canonical checkouts and live symlink targets are permanent,
not worktree cleanup targets. Verify removal from both disk and Git's list.
