---
name: html-feedback
description: Use whenever you create an HTML artifact and there is even a 1% chance it could prompt questions, selections, comments or feedback.
---

# HTML feedback

Keep feedback inside the HTML document and connect it to the current agent and conversation. Do this before presenting the artifact, even if it initially has no input controls.

Discover what the host actually supports. Use a supported bridge, or persist feedback through localStorage or another store that the agent can actually read. Verify access to the exact artifact and storage context. Do not invent postMessage targets, tool APIs or credentials to make it look connected.

Feedback must identify the artifact, the question or item, and the user's choice or comment. Keep enough context that the agent can respond without asking the user to reconstruct what they selected.

A dropdown or localStorage alone is not a connection. Distinguish saved feedback from feedback the agent has read. Only say feedback was received when delivery is confirmed.

Never replace in-document feedback with native questions, separate forms, instructions to type numbered choices in chat, or an export and upload chore. Do not remove the HTML controls and call that a feedback solution. The user must be able to select, question and comment inside the document without reconstructing their choices elsewhere.

If no working connection is available, explain the blocker and find a workable in-document route before presenting the artifact as connected. Do not substitute an outside-the-document fallback.

Receiving feedback is separate from permission to execute changes. A preference does not grant approval.

Before presenting it, enter a test choice or comment inside the HTML and confirm the current agent can read it with its context. If using persistence, verify the feedback survives reload and can be retrieved. Remove the test feedback afterward. A visual success state proves nothing.
