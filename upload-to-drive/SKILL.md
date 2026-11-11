---
name: upload-to-drive
description: whenever the user asks to clear up local space or move something to Google Drive, use this
---

# Upload to Drive

Use `rclone` for Google Drive uploads instead of the Google Drive MCP. Start with `rclone --help` and `rclone <command> --help`.

## Remotes

- `gdrive:` is the user's whole Google Drive.
- `content:` is an alias for Drive's Content folder, where media usually goes. See its folders with `rclone lsf content: --dirs-only`.

Every call prints a NOTICE saying rclone's shared Drive client_id is being retired in 2026. Tell the user once per session and link https://rclone.org/drive/#making-your-own-client-id.

## Calls

- Upload: `rclone copyto <local> "content:<dir>/<name>"` for a file, `rclone copy <local-dir> "content:<dir>"` for a directory.
- List: `rclone lsl content: --max-depth 3`.
- Verify: `rclone check <local-dir> "content:<dir>" --one-way` (Drive keeps MD5, so this compares hashes). For a single file, compare `rclone lsl` with `ls -l`.
- Share: `rclone link "content:<path>"`. This makes the file viewable by anyone with the link, so tell the user. Only link files you uploaded in this task or that the user named.

Calls hang when the machine sleeps or the network drops. Wrap each one in `timeout`. Give large files a long timeout and add `--progress` or `--stats 30s`. Retrying is safe because `copy`/`copyto` skip files that are already identical.

## Free up space

1. Find what is big with `du -sh`.
2. Check whether each candidate is already on Drive, matching by name and size.
3. Upload what is missing.
4. Verify every upload. The step is done when each file is listed as verified, with matching hash or size.
5. Propose the local deletions as a list of verified files only, and delete only after the user confirms.

## Guardrails

- Upload with `copy` or `copyto`. `sync` deletes on the remote and `move` deletes the local source without confirmation.
- Leave existing Drive files as they are. Move, rename, delete or reshare them only when the user asks.
- Keep credentials, tokens and signed URLs out of tracked files. `rclone config show` prints tokens, so never paste its output.
