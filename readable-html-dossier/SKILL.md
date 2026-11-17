---
name: readable-html-dossier
description: Use when creating a standalone HTML report, dossier, investigation brief, review findings document, or human-readable context page from agent research.
---

# Readable HTML Dossier

A dossier is a standalone HTML page that a human reads to make one decision. Its quality lives in the writing: the reader knows the answer from the first screen and finds the evidence behind every claim without hunting. The styling stays out of the way.

## Steps

1. **Name the decision.** Write down the decision or question the reader brings to this page, and your answer to it.
   Completion: the `<h1>` and first paragraph state the answer and what the reader should do about it.

2. **Shape sections around that decision.** Build sections from the material in hand; summary, findings, recommended actions, open questions, and sources are the usual pieces. A section earns its place by changing the decision. Add background only where the reader lacks it.
   Completion: every heading says what its section tells the reader, and no two sections carry the same point.

3. **Write findings by consequence.** Rank findings most consequential first. Each opens with what it means for the reader, then shows its evidence inline: `file:line` links, quotes, commands and their output. Add the next action and the uncertainty where they exist. A finding is as long as its content; a two-line finding stays two lines.
   Completion: every claim has its evidence beside it, and the first finding is the one the reader would act on first.

4. **Build from the scaffold.** Copy the scaffold in [REFERENCES.md](REFERENCES.md#scaffold) and follow its visual contract. When a `DOC_MAP.html` sits in the output folder or one above it, or the caller says the map will open this dossier, also embed the [reading progress tracker](REFERENCES.md#reading-progress-tracker). Use tables for comparisons, cards for findings, and callouts for uncertainty. When a diagram earns its place, build it with `architecture-diagram`. Save where the caller asks; use `/tmp` only for one-off reports.
   Completion: the file opens straight from disk, and every `h2` and `h3` carries a stable `id`.

5. **Look at it.** Render the page at about 1280px and 375px wide and view both renders, through the host's HTML preview tool when one exists, otherwise a headless screenshot with `/agent-browser`. Check that the answer sits in the first screen, the page never scrolls sideways, code blocks scroll inside themselves, and both themes stay legible.
   Completion: you have seen both renders and fixed what they showed.

6. **Hand it over.** Show the dossier through the host's HTML preview tool when one exists; otherwise open it in the user's browser as described in [REFERENCES.md](REFERENCES.md#browser-opening). Report the absolute path either way.
   Completion: the dossier is in front of the user and they have its path.
