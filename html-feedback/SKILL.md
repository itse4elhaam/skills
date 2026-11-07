---
name: html-feedback
description: Use whenever you create an HTML artifact and there is even a 1% chance it could prompt questions, selections, comments or feedback.
---

# HTML feedback

Give the user a real way to send feedback to the current agent and conversation. Do this before presenting the artifact, even if it has no input controls.

Discover what the host actually supports. Build and verify a supported return path. Do not invent postMessage targets, tool APIs, custom backends or credentials to make it look connected.

Feedback must identify the artifact, the question or item, and the user's choice or comment. Keep enough context that the agent can respond without asking the user to reconstruct what they selected.

A dropdown, localStorage, download or export button does not send feedback by itself. A visual success state proves nothing. Only say feedback was sent when delivery is confirmed.

If direct delivery is unavailable, say so before presenting it. Use an available native conversational input or feedback path, such as a chat reply tied to clearly labelled items. Remove controls that imply delivery. Do not silently turn feedback into an export and upload chore. Make any manual step explicit.

Receiving feedback is separate from permission to execute changes. A preference does not grant approval.

Before presenting it, send a test choice or comment through the actual return path and confirm the current agent can read it with its context. If using the conversational fallback, verify that input is available and tell the user exactly where to reply. Do not claim direct delivery for that fallback.
