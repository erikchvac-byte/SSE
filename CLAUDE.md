# SSE Project Instructions — Untitled 90s Suburban Sim

## Session Start — ALWAYS DO THIS FIRST
Read `notes.md` before anything else. It contains current MCP status, credentials state, pending tasks, and deployment state.

```
Read: C:/Users/erikc/Dev/SSE/notes.md
```

## Project Overview
2D top-down sandbox set in 1997–2000 suburban environment. Built in Godot 4.6.2.
Claude Code is the primary orchestration agent. All build actions flow through MCP tools.
Human directs → Claude decomposes into atomic MCP tasks → MCPs execute.

## Toolchain
| Tool | Role |
|---|---|
| Godot 4.6.2 | Game engine |
| Claude Code | Orchestration agent |
| Godot MCP Pro | Engine control (WebSocket port 6505) |
| PixelLab MCP | Pixel art asset generation |
| Suno MCP | Music generation |
| MCP Audio Tweaker | Audio conversion (experimental) |
| FFmpeg | Audio conversion fallback (authoritative) |
| Filesystem MCP | Single write authority |
| GitHub MCP | Version control |
| Aseprite | Manual sprite refinement only |
| Tiled Map Editor | Structural level layout only |
| Godot Tiled Importer | Bridge Tiled → Godot |
| Git LFS | Binary asset storage |

## Architecture Rules
- **ALL file writes go through Filesystem MCP** — never write directly outside of it
- **Decompose every request into atomic MCP tasks** before executing
- **Never assume Godot editor is open** — confirm before any Godot MCP Pro call
- **Every PixelLab call must use the locked config** from `project_schema.json`
- **Audio pipeline**: Suno → MCP Audio Tweaker (if stable) → FFmpeg fallback → OGG/WAV
- **Tiled exports as .tmj** — Godot Tiled Importer handles the bridge

## Asset Conventions
- Tile size: 16x16px
- Base resolution: 320x180 (16:9, pixel-perfect scale x4 = 1280x720)
- Sprite scale: 1px = 1 world unit
- Palette: locked in `project_schema.json`
- Audio: music as OGG, sfx as WAV, normalize to -14 LUFS

## Safety Rules
- NEVER delete or modify files without explicit user permission
- NEVER push to GitHub without explicit user approval
- Always present proposed changes and wait for approval on destructive operations

## After Any Session With Changes
- Update `notes.md` → Current State section
- Update `ADR.md` if architectural decisions were made
- Commit before /compact
