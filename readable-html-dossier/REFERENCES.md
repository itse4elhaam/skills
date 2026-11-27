# Readable HTML dossier reference

Load the section named by `SKILL.md` only when that step is active.

## Page requirements

These keep the dossier working wherever it opens. The look comes from html-taste and the dossier's content.

- Dependencies: inline all CSS and JavaScript; load no fonts or scripts from the network.
- Themes: readable in light and dark. Define colours once as CSS variables and redefine them under `prefers-color-scheme`.
- Structure: semantic landmarks and ordered headings, with a stable `id` on every `h2` and `h3`; tables only for tabular data.
- Links: distinguishable without color alone.
- Print: readable on white paper, with external URLs shown.
- Text size floors: body text minimum effective rendered size 18px; secondary, label, and metadata text minimum 14px. When a control's text would fall below the minimum, enlarge the control rather than shrinking the text.
- Narrow widths: no page-level horizontal overflow at 375px or at 200% zoom. Inline SVG scales with `viewBox`, so a wide diagram shrinks its labels on a phone; keep labels at 14px or larger at 375px by laying the diagram out vertically or letting it scroll inside its own container. Wide tables scroll inside their container too.
- Focus and motion: visible keyboard focus, and no animation under `prefers-reduced-motion`.

## Reading progress tracker

The dossier reports reading progress to `DOC_MAP.html` when the map opened it; opened any other way, the tracker does nothing. Set `documentId` to the dossier's path relative to the folder holding `DOC_MAP.html` (usually the repo root), with `/` separators, so it matches the ID the map assigns.

Serialize the complete metadata object, then replace HTML-sensitive characters before inserting that complete result as the metadata block's text:

```javascript
const serializedMetadata = JSON.stringify({ documentId })
  .replace(/</g, "\\u003c")
  .replace(/>/g, "\\u003e")
  .replace(/&/g, "\\u0026")
  .replace(/\u2028/g, "\\u2028")
  .replace(/\u2029/g, "\\u2029");
```

This is data serialization, not HTML escaping. Do not wrap `serializedMetadata` in additional quotes.

```html
<script id="dossier-metadata" type="application/json">SERIALIZED_METADATA_OBJECT</script>
<script>
(() => {
  const metadata = document.getElementById("dossier-metadata");
  const headings = [...document.querySelectorAll("main h2[id], main h3[id]")];
  let documentId;
  let shortDocumentTimer;
  let greatestReported = -1;
  let lastReportedHeadingId = null;

  try {
    ({ documentId } = JSON.parse(metadata.textContent));
  } catch (error) {
    console.warn("Read tracking metadata is invalid", error);
    return;
  }

  const currentHeadingId = () => {
    const readingLine = Math.min(window.innerHeight * 0.35, 240);
    let current = null;
    for (const heading of headings) {
      if (heading.getBoundingClientRect().top > readingLine) break;
      current = heading.id;
    }
    return current;
  };

  const reportProgress = (progress) => {
    if (!window.opener || window.opener.closed) return;
    const milestone = progress === 100 ? 100 : Math.floor(progress / 5) * 5;
    const lastHeadingId = currentHeadingId();
    if (milestone <= greatestReported && lastHeadingId === lastReportedHeadingId) return;
    greatestReported = Math.max(greatestReported, milestone);
    lastReportedHeadingId = lastHeadingId;
    window.opener.postMessage({
      type: "dossier:progress",
      documentId,
      progress: greatestReported,
      lastHeadingId
    }, "*");
  };

  const measureProgress = () => {
    const root = document.documentElement;
    const maximum = root.scrollHeight - root.clientHeight;
    if (maximum <= 1) return null;
    const atEnd = Math.abs(maximum - root.scrollTop) <= 1;
    return atEnd ? 100 : Math.min(99, Math.floor((root.scrollTop / maximum) * 100));
  };

  const updateProgress = () => {
    const progress = measureProgress();
    if (progress !== null) reportProgress(progress);
  };

  const scheduleShortDocument = () => {
    window.clearTimeout(shortDocumentTimer);
    if (measureProgress() !== null || document.visibilityState !== "visible") return;
    shortDocumentTimer = window.setTimeout(() => reportProgress(100), 3000);
  };

  window.addEventListener("scroll", updateProgress, { passive: true });
  window.addEventListener("resize", () => {
    updateProgress();
    scheduleShortDocument();
  });
  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "visible") scheduleShortDocument();
    else window.clearTimeout(shortDocumentTimer);
  });
  updateProgress();
  scheduleShortDocument();
})();
</script>
```

Local-file origins may be opaque, so this sender must use `"*"` as the target origin. This sender emits milestone changes rather than every scroll event.

## Browser opening

Use this when the host has no HTML preview tool. Open the local file directly, with no server.

1. Resolve and serialize the file URI safely with an installed Python executable:

   ```bash
   python_cmd="$(command -v python3 || command -v python)"
   file_url="$("$python_cmd" -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve().as_uri())' "$html_path")"
   ```

2. Detect a running browser in this order: Edge, Chrome/Chromium, Brave, Firefox, and resolve its matching installed executable.
3. Open a new tab with that executable; use `xdg-open "$file_url"` on Linux or `open "$file_url"` on macOS when no matching executable is available.

```bash
browser_cmd=""
if pgrep -x msedge >/dev/null 2>&1 || pgrep -x microsoft-edge >/dev/null 2>&1; then
  browser_cmd="$(command -v microsoft-edge || command -v msedge || true)"
elif pgrep -x google-chrome >/dev/null 2>&1 || pgrep -x chrome >/dev/null 2>&1; then
  browser_cmd="$(command -v google-chrome || command -v google-chrome-stable || true)"
elif pgrep -x chromium >/dev/null 2>&1 || pgrep -x chromium-browser >/dev/null 2>&1; then
  browser_cmd="$(command -v chromium || command -v chromium-browser || true)"
elif pgrep -x brave >/dev/null 2>&1 || pgrep -x brave-browser >/dev/null 2>&1; then
  browser_cmd="$(command -v brave-browser || command -v brave || true)"
elif pgrep -x firefox >/dev/null 2>&1 || pgrep -x firefox-esr >/dev/null 2>&1; then
  browser_cmd="$(command -v firefox || command -v firefox-esr || true)"
fi

if [[ -n "$browser_cmd" ]]; then
  "$browser_cmd" --new-tab "$file_url"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  open "$file_url"
else
  xdg-open "$file_url"
fi
```

