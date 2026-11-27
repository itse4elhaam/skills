---
name: readable-html-dossier
description: Use when creating a standalone HTML report, dossier, investigation brief, review findings document, or human-readable context page from agent research.
---

# Readable HTML Dossier

A dossier is a standalone HTML page the reader looks at to understand a situation and decide, fast. HTML earns its place over a chat reply by showing: the reader gets the point from headings and visuals alone, and reads prose only to go deeper.

## Steps

1. **Name the decision.** Write down the decision the reader brings to this page and your answer to it.
   Completion: the first screen holds the answer as a one-line headline and one visual that carries it.

2. **Give every point a visual.** List the points the reader needs, ranked most consequential first, and show each in the form that fits it:
   - flow, sequence, or architecture → diagram
   - options or trade-offs → comparison matrix
   - a change → before/after diff or side-by-side
   - ranking, severity, or size → scored table or bar strip
   - states and transitions → state diagram
   - events over time → timeline
   - structure or ownership → tree
   - a code location → short annotated snippet
   A point with no visual form becomes one callout.
   Completion: every section opens with its visual.

3. **Caption, don't explain.** Under each visual, write at most two sentences: what to notice and why it matters. Put the evidence (`file:line` links, quotes, command output) and any longer reasoning in a collapsed `<details>` beneath it.
   Completion: headings, visuals, and captions alone carry the whole argument, and every claim has its evidence one click away.

4. **Design and build the page.** Design it with [html-taste](../html-taste/SKILL.md) for this dossier's content and reader, and meet the [page requirements](REFERENCES.md#page-requirements). Draw diagrams as inline SVG with `/diagram-design`, interactive system flows with `/architecture-diagram`, and charts with `/dataviz`. When a `DOC_MAP.html` sits in the output folder or one above it, or the caller says the map will open this dossier, also embed the [reading progress tracker](REFERENCES.md#reading-progress-tracker). Save where the caller asks; use `/tmp` only for one-off reports.
   Completion: the file opens straight from disk with no network requests, and every `h2` and `h3` carries a stable `id`.

5. **Look at it.** Render the page at about 1280px and 375px wide and view both renders, through the host's HTML preview tool when one exists, otherwise a headless screenshot with `/agent-browser`. Skim each render the way the reader will: headings, visuals, captions.
   Completion: the skim gives the answer and the reason at both widths, visuals stay legible in both themes, the page never scrolls sideways, and you fixed what the renders showed.

6. **Hand it over.** Show the dossier through the host's HTML preview tool when one exists; otherwise open it in the user's browser as described in [REFERENCES.md](REFERENCES.md#browser-opening). Report the absolute path either way.
   Completion: the dossier is in front of the user and they have its path.
