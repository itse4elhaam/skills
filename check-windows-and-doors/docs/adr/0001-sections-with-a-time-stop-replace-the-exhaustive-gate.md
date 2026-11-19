---
status: accepted
---

# Sections with a time stop replace the exhaustive gate

The skill inspects one section at a time, to a verdict per opening, and stops a section that overruns its time range. It no longer requires every operation in the repository to be traced across nine control families before it may finish. We made this change because the exhaustive gate could not end on a large application.

On 3 November 2026 a first run on Bloom found two high-severity payment defects in ten minutes and stopped with 483 of 1,465 operations untouched. In response the skill was changed to forbid stopping while any trace was partial. The next run reached 18 findings in about six hours, then spent a further day on bookkeeping. Its unreviewed count rose from 483 to 1,728 as the list absorbed framework routes, outbound calls and jobs, and its own estimate was "several more days".

A short run that leaves sections "not inspected" is the intended result. Before restoring an all-or-nothing completion rule, read those numbers.

## Considered options

- **Keep the exhaustive gate and add subagents.** The Bloom run had both and still could not say how far along it was.
- **Cap the run at a fixed number of operations.** This bounds cost but leaves the choice of what to inspect to the agent.
- **Sections chosen by the user, each with a time range and a stop.** Chosen. Progress is countable as sections done out of the total, and the user decides where the time goes.

## Consequences

- 1,339 of Bloom's operations were routes the framework shipped. These are now inherited openings: counted on the map and not inspected.
- A defect in a section nobody chose stays unfound. The map shows that section as "not inspected" so the gap is visible.
