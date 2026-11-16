---
name: logging-and-monitoring
description: Leave durable diagnostic logging when implementing or fixing runtime behavior, especially in internal apps, desktop tools, CLIs and background jobs. Use so a later agent can trace a failure that cannot be reproduced, or when adding logs, monitoring or a diagnostics command.
---

# Logging and monitoring

Leave enough evidence that the next agent can investigate a failure without reproducing it. Do this while implementing runtime behavior, before the first unexplained incident.

Trace the changed flow. At each meaningful boundary, decision and state transition, ask: if this fails once tomorrow, what would distinguish the causes? Record normal execution and failures, including entry, handoffs, completion, cancellation, timeout, retries, recovery and skipped work where applicable.

Use the existing logger. Prefer structured events with stable names, timestamps, severity, app revision and an operation or session ID carried across asynchronous work and subprocesses. Include safe state, timings, attempt numbers, relevant device/configuration identities and error causes or stacks. Log failures where their context is known; avoid duplicate exceptions at every layer.

Keep useful events enabled by default; temporary debug probes are separate. Rate-limit repeated events and hot loops while retaining failures, important transitions and dropped-event counts. CLI diagnostics belong on stderr or a log sink, preserving machine-readable stdout.

Define per-file, total-size and age limits, rotate logs and state the retention window. Bound buffering and write overhead. Failed writes or full disk must not hide the original error or break the operation; expose degraded logging without recursive errors. Keep logs outside the source tree with appropriate access. Redact secrets and private content before writing; do not dump payloads, recordings or environment variables.

For unattended work, expose the current operation, last progress, failures and recovery state so an agent can distinguish healthy, stalled and dead. Reuse monitoring; add bounded health signals where a named failure would otherwise go unseen. Verify a monitor observes a representative event and survives it before calling it ready.

Give the next agent an exact retrieval path or command, filterable by time and operation ID, including rotated files. If local retention is insufficient, propose compression, archival or an existing collector with its cost and access needs. Uploads and new services need authorization.

Before delivery, safely exercise the flow and a controlled failure. Read the retained events and reconstruct the sequence. Check applicable retries, timeouts, cancellation, restart, redaction, rotation and unavailable storage. Report remaining blind spots. Extensive logging means useful flow coverage, not unlimited output.
