# SSE Project Notes

## Current State
**Last Updated**: 2026-04-17
**Phase**: Pre-Phase-1 — GDD v0.2 drafted, project ready, no scenes built yet.

## Environment
- OS: Windows 11
- Shell: Git Bash / PowerShell
- Godot: 4.6.2 stable (C:\Program Files\Godot\)
- FFmpeg: 8.1 (via winget, in PATH)
- Node.js: v24.13.0
- Python: 3.13.5
- Git LFS: 3.7.0
- mcp-suno: 2026.4.8.4 (pip installed)

## MCP Status
MCP servers are registered in `~/.claude.json` (NOT project `.claude/settings.json` — Claude Code only loads MCPs from user config).

| MCP | Status | Notes |
|---|---|---|
| Filesystem MCP | LIVE | scope: `C:/Users/erikc/Dev/SSE` |
| Godot MCP Pro | LIVE | v1.7.0 bridge, v1.6.0 plugin, WebSocket port 6505, editor connected |
| PixelLab MCP | LIVE | key configured in user config |
| GitHub MCP | NOT LOADED | PAT was exposed — regenerate before re-adding |
| Suno MCP | NOT LOADED | no API key yet — add when we hit Phase 7 |
| FFmpeg | LIVE | authoritative audio converter, in PATH |
| MCP Audio Tweaker | REMOVED | FFmpeg is authoritative per GDD §11 |

## Godot Editor
- Editor: OPEN with SSE project loaded
- Project: "Untitled 90s Suburban Sim"
- Viewport: 640×360 (updated this session from 320×180)
- Plugin: Godot MCP Pro enabled, autoloads registered
- Current open scene: `res://Home68.tscn` (placeholder — slated for deletion)
- Main scene: NOT SET

## Pending Manual Steps
1. [!] **Regenerate GitHub PAT** at https://github.com/settings/tokens — was exposed in prior conversation
2. [ ] Install Godot Tiled Importer plugin (needed when we start Tiled map work)
3. [ ] Get Suno API key when we reach Phase 7 (audio)
4. [ ] Decide on palette (GDD §11 gap) before first PixelLab asset call

## Design Documents
- **`GDD.md`** — canonical design doc, v0.2.1 (dystopian reframe + palette locked). ALL design decisions live here.
- **`palette.md`** — canonical palette spec, v1.0. 10-color system; self-awareness gates UI reveal. PixelLab prompt templates included.
- **`CLAUDE.md`** — session instructions. Points at GDD.md for design.
- **`ADR.md`** — architectural decision log. Aligned with GDD as of Session 002 (ADR-008 through ADR-012 added).
- **`document_pdf.pdf`** — original pipeline/design session doc from prior session.

## Credentials Storage
- Project-level `.claude/settings.json` mcpServers section is INERT — Claude Code ignores it.
- All credentials in `~/.claude.json` (user config). Gitignored by default (outside project).
- Never commit credentials to GitHub.

## Git
- Repo: initialized locally
- LFS patterns configured in `.gitattributes`
- Remote: none configured (pending PAT regeneration)
- Uncommitted: many changes staged from this and prior session

## Known Issues
- `project_schema.json` referenced in ADR-004 doesn't exist. Palette/asset config now lives in `palette.md` and `GDD.md`. ADR-004 kept for history but is effectively superseded by ADR-012.
- The 4 unique NPCs (Loyalist/Rival/Burnout/Authority per GDD §9.1) have no names, designs, or dialogue yet.
- GitHub PAT exposure: both an old and current PAT are in `.claude/settings.json` working tree and prior git history (commit 960fa44). PixelLab key also in working tree. Remediation deferred per user — must be done before first push.

## What's Next (Phase 1 Build)
Per GDD Phase 1 scope (§10): **assigned domicile + yard + adjacent sector street.**

Immediate next steps:
1. Create `res://resources/palette.tres` — named Color exports for the 10 palette values
2. First scene — the youth-unit's bedroom (interior). Starting location.
3. First tileset via PixelLab using `palette.md` §5 prompt template — interior floor/wall/door
4. Player controller (CharacterBody2D, 4-direction movement, 32x32 collision)
5. Always-on minimap UI skeleton (GDD §10, empty/fog-only for now)
