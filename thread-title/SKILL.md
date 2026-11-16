---
name: thread-title
description: Check the current thread title whenever a new user prompt arrives. Keep it aligned with active work, including a scope pivot or two work paths proceeding together.
---

# Thread title

On each new user prompt, compare the current title with the work still underway. Read the prompt in context. A follow-up can refine the same task without changing its scope.

Keep the title when it still fits. Rename when the work pivots, the title describes obsolete work, or a second active path makes it incomplete. If both paths continue, name both. Drop a completed path when it no longer describes the thread's purpose.

Use a few concrete words that someone can scan in the thread list. Name the work, not the conversation about it. Avoid vague titles like "Follow-up discussion", progress reports, and a history of earlier tasks. Do not rename for every small follow-up.

For example, keep "Fix checkout retries" through a retry-test follow-up. If work shifts to invoice exports, use "Fix invoice exports". If both continue, use "Checkout retries and invoice exports".

## Change the right thread

Discover the host's available thread tools and read their schemas. Get the current title from trusted runtime context or a supported read tool. Never guess the current thread from its title, the newest result, or the workspace path.

In T3 Code, `t3_thread_list` returns `currentThreadId`. Find that exact thread's title in the response, or read it with `t3_thread_read`. `t3_thread_update` supports `action: "rename"` with `title`; omitting `threadId` targets the current host thread. Prefer that current-thread default. If an explicit ID is required, use only the verified current ID. Read the available schema rather than assuming these capabilities exist in another host.

A subagent may share its parent's host thread. Do not retitle that thread around the subtask. Leave the parent title to the parent unless explicitly assigned to rename it with the full active scope.

Check the rename result before claiming success. If the result is uncertain, read the current title before retrying. If the title, current identity, or rename capability is unavailable, leave it unchanged and briefly state the limitation when a rename is needed. Never invent a tool or claim a rename that did not happen.

This skill requests a check on every prompt. Automatic skill selection does not guarantee a runtime hook or execution on every turn. Do not add hooks or global settings to compensate unless the user asks.
