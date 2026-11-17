---
name: github-cli-only
description: Use the GitHub CLI for every GitHub read or write in Codex, including repositories, issues, pull requests, reviews, comments, and checks. The GitHub connector is prohibited because it uses a different account.
---

# Interact with GitHub through gh

- Use the GitHub CLI (`gh`) for all GitHub reads and writes. Never call the GitHub connector or any of its tools, including for lookups, verification, or fallback. Carry this rule into any delegated GitHub work.
- Use [GitHub GraphQL First](../github-graphql-first/SKILL.md) as the supporting skill for structured queries. Prefer ordinary `gh` subcommands for direct operations such as creating an issue. Use the host PR link and watch tools when required after a CLI operation.
- Before the first GitHub write to a host in a task, check the effective account with `gh api graphql --hostname <host> -f query='{ viewer { login } }' --jq .data.viewer.login`. On github.com, use `itse4elhaam` unless the user explicitly requests a different account. If the account differs or authentication fails, stop the write and report the blocker. If `gh` is unavailable, report that instead of falling back to the connector.
- Verify the target repository and account to assign or mention. Put multiline issue bodies and comments in temporary files and pass them with `--body-file`. Read back the result through `gh`.
