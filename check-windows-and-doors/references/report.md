# Notes and report

## The section note

Write one file per inspected section at `.security/sections/<section>.md` when the section ends or is stopped:

- Section, commit, date, minutes spent, and whether it finished or stopped at N of M.
- One row per opening:

| ID | Opening | Verdict | Proof (file:line) | Finding or missing evidence |
| --- | --- | --- | --- | --- |

- The findings in full, then the "worth hardening" lines.
- Any local run: command, isolation evidence, expected and actual result.

Update the map's `Inspected` column and, after the first finished section, its time ranges.

## Tiers

Rank each finding by its break-in story, not by its category. The first two tiers hold findings. The third holds lines attached to `closed` openings.

- **Fix now.** A stranger or any signed-in user can do it with only the application and patience. Another customer's order behind a serial ID belongs here. So does an exported action with no check, and a one-time-code sender anyone can fire at a victim's phone without limit.
- **Fix soon.** The story needs something hard to get: a random ID that must leak first, an insider role, exact timing.
- **Worth hardening.** No story exists. A missing cap or a weak default that would make a future mistake worse. One line each.

## A finding

- A title that names the consequence, and its tier.
- The break-in story in four lines: who, what they must know or guess, the steps, what they walk away with.
- The source lines that show the failing part, and the result of a local run if there was one. Say whether the proof is static, run locally, or both.
- What you looked for that could have closed it and did not find.
- The smallest fix, and a test that refuses the attacker while still serving the legitimate caller.

Group openings that fail for the same reason into one finding and list the affected IDs.

Example of the form only:

> **Any signed-in customer can read any other customer's invoice. Fix now.** Who: any signed-in customer. Must know: nothing, since invoice IDs count up from 1. Steps: request `/api/invoices/1042` with their own session. Walks away with: another customer's name, address and order lines. The route checks the session at `invoices/route.ts:14` and selects by ID alone at `:22`. Fix: add the customer ID to the query. Test: customer A is refused B's invoice, and B still gets it.

## Make it hard to repeat

Add this section when two or more findings share a cause, or when the house has no single place that every opening of a kind passes through.

Propose one structural change that makes the mistake hard to write. The usual shape is a factory or wrapper that every server action or route is created through, which checks the session and parses input before the handler runs, so the unprotected version does not compile or does not register. Pair it with a check that fails the build when code goes around it, such as a lint rule or a test that lists every export.

Name the findings it would have prevented. Propose it, and implement it only when the user asks.

## The report in the chat

In this order, and nothing above the first item:

1. Fix-now findings.
2. Progress: sections inspected out of the total, openings with each verdict, time spent.
3. Fix-soon findings.
4. Make it hard to repeat, when it applies.
5. `can't tell` openings with the evidence each needs.
6. Worth hardening.
7. Sections not inspected, in ranked order, with their time ranges.

When no opening is `open`, say that for the sections inspected at that commit, and still give items 2, 5 and 7.
