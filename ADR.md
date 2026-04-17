# Architecture Decision Record — Untitled 90s Suburban Sim

## Overview
2D top-down sandbox game set in 1997–2000 suburban America. Built in Godot 4.6.2.
Claude Code orchestrates all build actions through MCP tools. Human-in-the-loop pipeline
where every request is decomposed into atomic MCP-executable tasks before execution.

## ADR-001: Godot 4 as Game Engine
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Need a 2D game engine suitable for top-down sandbox with MCP integration.
**Decision**: Godot 4.6.2
**Rationale**: Strong 2D tooling, GDScript/C# support, active MCP integration (Godot MCP Pro), free and open source, large community.
**Consequences**: Requires Godot 4.4+ minimum for Godot MCP Pro compatibility. Lock version to avoid plugin breakage.

## ADR-002: Claude Code as Primary Orchestration Agent
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Need a way to coordinate asset generation, engine control, version control, and file operations in a unified pipeline.
**Decision**: Claude Code acts as the orchestration layer, decomposing all requests into atomic MCP tasks.
**Rationale**: Claude Code's native MCP support makes it ideal for coordinating multiple specialized tools. Human-in-the-loop keeps creative control with the user.
**Consequences**: All actions must be expressible as MCP tool calls. Claude cannot act on systems directly — everything routes through MCPs.

## ADR-003: Filesystem MCP as Single Write Authority
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Multiple MCPs (PixelLab, Godot MCP Pro, Suno) all produce file outputs. Without a single write authority, race conditions and path conflicts are likely.
**Decision**: All file writes route through Filesystem MCP exclusively.
**Rationale**: Prevents concurrent write conflicts, provides a single audit trail, enforces path conventions.
**Consequences**: Slightly more steps per operation. All MCPs must hand off outputs to Filesystem MCP rather than writing directly where possible.
**Note**: Two CVEs disclosed (CVE-2025-53109, CVE-2025-53110) — local-only pipeline, low risk. Pin version.

## ADR-004: Shared Project Schema for Asset Consistency
**Status**: Accepted
**Date**: 2026-04-16
**Context**: PixelLab generates non-deterministic outputs. Without locked parameters, art style will diverge across sessions.
**Decision**: All asset generation calls use locked config from `project_schema.json` (palette, pixel scale, tile size, style prefix).
**Rationale**: Ensures visual coherence across all AI-generated assets across sessions and tools.
**Consequences**: Requires discipline to always reference schema before calling PixelLab. Schema changes require retroactive asset updates.

## ADR-005: Audio Pipeline with FFmpeg Fallback
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Suno outputs MP3. Godot requires OGG (streaming music) and WAV (sfx). MCP Audio Tweaker handles conversion but is pre-release.
**Decision**: Primary path = MCP Audio Tweaker. Fallback = direct FFmpeg call. FFmpeg is authoritative.
**Rationale**: MCP Audio Tweaker is convenient but experimental. FFmpeg is stable and already installed.
**Consequences**: Must verify MCP Audio Tweaker on each session before relying on it. Always have FFmpeg command ready.
**FFmpeg command**: `ffmpeg -i input.mp3 -c:a libvorbis -q:a 4 output.ogg`

## ADR-006: Git LFS for Binary Assets
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Sprites, audio, and Godot binary files will bloat standard Git history rapidly.
**Decision**: Git LFS for all binary asset types (see .gitattributes).
**Rationale**: Keeps repo size manageable, standard practice for game projects.
**Consequences**: Requires Git LFS initialized on all contributor machines. LFS bandwidth costs on GitHub for large projects.

## ADR-007: Tiled Map Editor for Level Layout
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Structural level layout benefits from a dedicated visual tool. Godot's built-in tilemap editor is sufficient but Tiled offers better workflow for large world design.
**Decision**: Tiled for structural layout only. Exports as .tmj. Godot Tiled Importer bridges to Godot.
**Rationale**: Tiled provides superior world-building UX for large maps. .tmj (JSON) format is human-readable and git-diffable.
**Consequences**: Requires Godot Tiled Importer plugin installed and configured. Tile size and layer naming must match schema exactly.

## Technical Constraints
- Godot 4.4+ required (Godot MCP Pro hard requirement)
- Node.js 18+ required (Godot MCP Pro server)
- Godot editor must be open for any Godot MCP Pro calls
- All pixel art: 16x16px tiles, locked palette
- Audio: OGG for music, WAV for sfx, -14 LUFS normalized

## Testing Results
- Godot 4.6.2: installed and verified ✅
- FFmpeg 8.1: installed and verified ✅
- Node.js v24.13.0: verified ✅
- Python 3.13.5: verified ✅
- Git LFS 3.7.0: verified ✅
- mcp-suno 2026.4.8.4: installed ✅
- Godot MCP Pro: PENDING purchase
- PixelLab MCP: PENDING API key
- MCP Audio Tweaker: PENDING install

## Known Issues
- Godot MCP Pro not yet purchased/installed
- PixelLab and Suno credentials not yet obtained
- MCP Audio Tweaker experimental — FFmpeg is fallback
- GitHub remote not yet configured

## Open Questions
- Which Suno MCP implementation is most stable? (mcp-suno via AceDataCloud selected — verify)
- Will PixelLab style anchoring be sufficient for full game consistency?
- Tiled Importer plugin — which version is compatible with Godot 4.6.2?

## Future Considerations
- Consider Git LFS bandwidth costs if asset library grows large
- May need custom PixelLab prompt templates per asset category
- Evaluate MCP Audio Tweaker stability after first use

## Key Files
- `CLAUDE.md` — session instructions
- `notes.md` — current state and credentials status
- `project_schema.json` — locked asset generation config
- `.claude/settings.json` — MCP server configurations
- `.gitattributes` — Git LFS patterns
- `godot_project/project.godot` — Godot project root

## Change Log
- 2026-04-16: Project scaffolded. All dependencies installed except Godot MCP Pro, PixelLab, Suno credentials.
