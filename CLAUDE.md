# SSE Project Instructions — Untitled 90s Suburban Sim

## Session Start
Always read:
1. `notes.md` — current state (repo, MCP, env)
2. Open GitHub Issues at github.com/erikchvac-byte/SSE/issues — current open work

Read on-demand (announce which are being skipped, with a one-line reason):
- `GDD.md` — when the task touches game design
- `ADR.md` — when the task touches architecture

If scope shifts mid-session to touch design or architecture, read the relevant doc at that point.

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

## Asset Review Workflow
- Generated images land in `assets/_pending/` (gitignored). Nothing enters `assets/` or git until approved.
- Default review mode: **user opens the PNG manually.** Claude states filename, prompt, seed/settings and waits.
- Claude **must flag for inline review** (and offer to display it via Read) when any of these apply:
  - First asset in a new series — sets the precedent for batch members
  - New character, new location, or new stylistic territory (no prior reference in `assets/`)
  - Palette-sensitive or 90s-aesthetic-critical (hue/saturation could drift)
  - Silhouette/readability matters at 32×32 (gameplay-visible sprite)
  - PixelLab output looks off to Claude (artifacts, wrong proportions, prompt bleed)
  - Deviates visibly from a sibling asset already committed
- Flag format: `⚠ recommend inline review — reason: <one line>`. User decides yes/no.
- For routine batch members that match an already-approved reference, skip the flag — user opens manually.

## Safety Rules
- NEVER delete or modify files without explicit user permission
- NEVER push to GitHub without explicit user approval
- Always present proposed changes and wait for approval on destructive operations

## Records Discipline (ADR-013)
Each concern has exactly one home. Do not duplicate across files.

| File | Purpose | Mutability |
|---|---|---|
| `notes.md` | Current state only | Mutable. **Delete stale items, do not annotate them.** No "Known Issues", "Pending", "Change Log", or "What's Next" sections — those belong elsewhere. |
| `ADR.md` | Architectural decisions | Immutable. To change a decision, append a new ADR that supersedes the old. Never edit a prior entry. |
| `Sessions/*.md` (Obsidian vault) | Behavioral log | Append-only. One file per session. |
| GitHub Issues | Open work | External. Close when done. |

When a task is resolved: delete it from `notes.md`, close its GitHub Issue, done. No archival, no struck-through lines, no "moved to X" breadcrumbs.

## Obsidian Vault Rule
The Obsidian vault at `C:\Users\erikc\Desktop\DesktopFolder\MeNew\SSE\` is reference + behavioral log, not canonical. Before reading or writing any file there, **announce what I'm opening and what I see** — check gate to avoid confusion with repo-side canonical files.

## After Any Session With Changes
- Prune `notes.md` — delete resolved items, update current state in place
- Add new ADRs to `ADR.md` only if architectural decisions were made (no edits to prior ADRs)
- Write a new session log in the Obsidian vault `Sessions/` folder
  - Filename: `Session NNN - YYYY-MM-DD.md`
  - Log what the user **did** — actions, decisions, missteps, friction points
  - Behavioral research, not a changelog — capture the process
- File any new open work as GitHub Issues
- Commit before /compact
