# SSE Project Instructions — Untitled 90s Suburban Sim

## Session Start — ALWAYS DO THIS FIRST
Read in order:
1. `notes.md` — current MCP status, credentials, pending tasks, deployment state
2. `GDD.md` — canonical game design document (locked decisions, known gaps)

## Project Overview
2D top-down open-world sim. Ambient dystopia in a fictional 1997 American suburb compound.
Built in Godot 4.6.2. Claude Code orchestrates all build actions through MCP tools.
Human directs → Claude decomposes into atomic MCP tasks → MCPs execute.

**`GDD.md` is canonical for all design decisions.** If CLAUDE.md and GDD.md conflict, GDD.md wins — flag the drift and update CLAUDE.md.

## Toolchain
| Tool | Role |
|---|---|
| Godot 4.6.2 | Game engine |
| Claude Code | Orchestration agent |
| Godot MCP Pro | Engine control (WebSocket port 6505) |
| PixelLab MCP | Pixel art asset generation |
| Suno MCP | Music generation |
| FFmpeg | Audio conversion (authoritative) |
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
- **Every PixelLab call must use the locked config** — see GDD §2 and §11 (palette TBD)
- **Audio pipeline**: Suno → FFmpeg → OGG (music) / WAV (sfx), normalized to -14 LUFS
- **Tiled exports as .tmj** — Godot Tiled Importer handles the bridge

## Asset Conventions
- Tile size: 32x32px
- Sprite size: 32x32px (characters match tile grid)
- Base resolution: 640x360 (16:9, pixel-perfect scale x2 = 1280x720)
- Sprite scale: 1px = 1 world unit
- Palette: TBD — see GDD §11 Known Gaps
- Audio: music as OGG, sfx as WAV, normalize to -14 LUFS
- Always-on minimap w/ fog-of-war is a UI requirement (per GDD §10)

## Safety Rules
- NEVER delete or modify files without explicit user permission
- NEVER push to GitHub without explicit user approval
- Always present proposed changes and wait for approval on destructive operations

## After Any Session With Changes
- Update `notes.md` → Current State section
- Update `ADR.md` if architectural decisions were made
- Write a new session log in `C:\Users\erikc\Desktop\DesktopFolder\MeNew\SSE\Sessions\`
  - Filename: `Session NNN - YYYY-MM-DD.md`
  - Log what the user **did** — actions, decisions, missteps, friction points
  - This is behavioral research, not a changelog — capture the process
- Commit before /compact
