---
name: audit-docs
description: Audit a codebase's documentation for unique knowledge, reconstruction evidence, precision, plain language, redundancy, and length.
---

# Audit docs

The purpose is to keep the knowledge we would otherwise lose, with as little documentation as possible.

Audit ALL documentation in the supplied codebase. Read its AGENTS instructions first. Inventory docs beyond the docs folder, including READMEs, agent instructions, ADRs, runbooks, inline documentation, and generated references. Account for every item. State exclusions, unreadable material, and coverage gaps. A bounded sample is only a sample, never a complete audit.

Work read-only unless the user requests edits or deletion.

For each section, ask: if this disappeared, what information could we NOT reconstruct from code, configuration, tests, explanatory commit messages and changes, linked issues/PRs, or another existing authoritative source?

Trace the actual claims. Cite the doc path and section or lines, then the concrete reconstruction source and what it proves. Use source paths and symbols/lines, commit hashes and explanations, or issue/PR links and passages. Calling something "implementation" is not evidence. A doc appearing in its own git history, or another copy of that doc, proves nothing. Compare explanatory commit messages and non-doc source/test/config changes or independent sources. Code showing a choice does not explain why it was made.

Keep unique decision rationale, constraints, and context. An ADR title earns no exemption. Trace its actual why and check whether that explanation already exists elsewhere. If external evidence is unavailable, mark the claim unverified and preserve it pending verification. Say where you searched before calling a fact unique.

Flag restatements of what/how the system works, copied framework guidance, implementation inventories, stale test/deployment logs, and duplicate policy. For mixed docs, classify sections separately. Preserve unique facts such as an owner's analytics mandate while replacing event inventories with links to their source owners. Link duplicate policy to its authority; preserve the authority itself.

Also check ambiguous claims, missing conditions, unexplained terms, repetition, and excess words. Suggest precise, plain wording. Short does not mean useful, and long does not mean redundant.

Use these advisory word limits as starting points: README 500, agent instructions 500, decision record 400 per decision, feature/context doc 600, runbook 800, index 150. For other types, propose a limit that fits the reader's task. Explain exceptions briefly, such as a safety procedure that needs complete steps. Limits are review signals, not deletion rules. Never split a document merely to pass them.

Return a concise audit: coverage, docs/sections that fail and why, reconstruction evidence, unique information that remains, unverified claims, and the smallest removal, link, or rewrite for each finding. Include word counts and applicable limits. Keep the report proportional to the findings. Recommend whole-file removal only when every section is accounted for and no unique or unverified information remains.
