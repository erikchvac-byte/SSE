# SSE Project Notes

**Current state only.** If an item here is no longer true, delete it — do not annotate or archive. Decisions live in `ADR.md`. Open work lives in GitHub Issues (github.com/erikchvac-byte/SSE/issues).

## Phase
Phase 1 scaffold in place — GDD v0.2.2, palette resource + minimap UI + bedroom scaffold scene + placeholder player. No real sprites yet; all visuals are palette-colored rects via _draw().

## Environment
- OS: Windows 11
- Shell: Git Bash / PowerShell
- Godot: 4.6.2 stable (`C:\Program Files\Godot\`)
- FFmpeg: 8.1 (winget, in PATH)
- Node.js: v24.13.0
- Python: 3.13.5
- Git LFS: 3.7.0
- mcp-suno: 2026.4.8.4 (pip)
- git-filter-repo: 2.47.0 (pip)

## MCP Status
Authoritative config: `~/.claude.json`. Project `.claude/settings.json` has no `mcpServers` block — Claude Code ignores it anyway.

| MCP | Status | Notes |
|---|---|---|
| Filesystem MCP | LIVE | scope: `C:/Users/erikc/Dev/SSE` |
| Godot MCP Pro | LIVE | v1.7.0 bridge, v1.6.0 plugin, WebSocket 6505 |
| PixelLab MCP | LIVE | key in `~/.claude.json` |
| GitHub MCP | REGISTERED | activates on next Claude Code restart |
| Suno MCP | NOT LOADED | API key pending |
| FFmpeg | LIVE | in PATH |

## Godot Editor
- Plugin Godot MCP Pro enabled
- Viewport: 640×360
- Main scene: not set

## Design Documents
- `GDD.md` — canonical design (v0.2.2)
- `palette.md` — canonical palette (v1.0)
- `ADR.md` — immutable architectural decisions (15)
- `CLAUDE.md` — session protocol
- `document_pdf.pdf` — original design reference

## Credentials
- `~/.claude.json` — live MCP credentials (user-scope, outside repo)
- `.env` — local env vars, gitignored
- Project `.claude/settings.json` — permissions only, no secrets

## Git
- Remote: https://github.com/erikchvac-byte/SSE (public)
- Branch: `master` tracks `origin/master`
- LFS patterns in `.gitattributes`

## Records Discipline
- `notes.md` — current state (this file). Mutable. Stale items are deleted, not struck through.
- `ADR.md` — decisions. Immutable. To change a decision, add a new ADR that supersedes the old.
- `Sessions/*.md` (Obsidian vault) — behavioral log. Append-only.
- GitHub Issues — open work.
