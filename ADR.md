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

## ADR-008: GDD.md as Canonical Design Authority
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Design decisions were scattered across CLAUDE.md, ADR.md, and the original pipeline PDF. Contradictions emerged (tile size 16 vs 32, viewport 320x180 vs 640x360, Tiled .tmj vs .tmx). No single source of truth for game design existed.
**Decision**: `GDD.md` at project root is canonical for all design decisions. CLAUDE.md and ADR.md reference it. On conflict, GDD.md wins and other files are updated to sync.
**Rationale**: Design decisions decay quickly without a single authoritative doc. Splitting rules from design lets CLAUDE.md stay short (~40 lines) while GDD grows.
**Consequences**: Every design change must update GDD.md. Stale GDD = stale everything.

## ADR-009: 32x32 Tiles and 640x360 Viewport (Supersedes ADR-004 Specs)
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Original specs (16x16 tiles, 320x180) were inferred early. Design session locked 32x32 per PDF and Stardew readability reference; viewport must show enough tiles for map comprehension at 32x32 scale.
**Decision**: Tile size 32x32px. Viewport 640x360 (×2 pixel-perfect = 1280x720). ~20x11 tiles visible on screen. Always-on minimap with fog-of-war is a UI requirement for scope visibility beyond viewport.
**Rationale**: 32x32 matches PDF spec, Stardew reference, and PixelLab native tile output. 640x360 is the smallest viewport that gives enough on-screen tiles for open-world readability.
**Consequences**: All asset generation and PixelLab prompts must enforce 32x32. Minimap is a Phase 1+ UI requirement, not optional. `project.godot` updated this session.
**Testing**: `project.godot` viewport values updated. Will verify visually once first scene is loaded.

## ADR-010: Dual-Register Terminology System
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Game tone shifted from "Catcher in the Rye vibes" to "Catcher × Severance ambient dystopia." Needed a concrete mechanic, not just atmosphere.
**Decision**: Every concept has two names. Surface vocabulary ("mom," "school," "home") used in casual NPC speech. Institutional vocabulary ("assigned custodian," "Reeducation Facility," "assigned domicile") used in paperwork, signage, PA systems, official forms. Full mapping table in `GDD.md` §3.
**Rationale**: The dissonance between the two registers IS the horror. Matches Severance reference exactly. Unlike a pure Orwellian setting, this creates a cognitive gap the player slowly notices.
**Consequences**: All asset text (signs, paperwork, HUD) and all NPC dialogue must be written to register. Writing cost increases slightly. Pays off in cohesion.

## ADR-011: Self-Awareness Stat as UI Reveal Mechanic
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Player decided the protagonist "slowly wakes up" to the dystopia rather than knowing from frame one. Needed a mechanical implementation that wasn't just a narrative flag.
**Decision**: The `self_awareness` stat (0–100) gates what UI colors and institutional vocabulary are visible to the player. Low awareness = only environment colors + surface vocabulary visible. High awareness = UI colors (CRT green, amber, magenta) appear on in-world signage and HUD; institutional vocabulary replaces surface vocabulary in labels.
**Rationale**: Makes the awakening arc a literal, visible mechanic rather than implied narrative. Every stat gain is visible feedback. Ties character creation choices (which set starting self-awareness) directly to starting visual experience.
**Consequences**: Requires a shader layer that gates color visibility based on stat. UI text rendering must swap between surface and institutional strings dynamically. More complex than a static UI but a core aesthetic feature.

## ADR-012: 10-Color Palette System with Set Separation
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Palette lock needed before first PixelLab call. User proposed a 10-color system with hard separation between environment and UI color sets; specific hex values needed retuning to fit the uncanny-suburb tone rather than cartoon-bright.
**Decision**: 5 ENVIRONMENT + 3 UI + 1 BRIDGE + 1 GLOBAL BASE. Full spec in `palette.md`. Environment set tuned hyperreal-uncanny (1997 suburb slightly too vivid). UI set tuned 1997-CRT-computer with one "glitch" magenta. Hard separation enforced in sprite generation; bleed controlled by shader tied to self-awareness (ADR-011).
**Rationale**: Color separation is the central aesthetic mechanic. The per-screen budget (3–5 env, 1–2 ui) forces disciplined scenes. PixelLab prompt template in `palette.md` §5 enforces the lock per generation call.
**Consequences**: Every PixelLab call must include the palette-lock prompt block. Palette values stored in `res://resources/palette.tres` (TBD) so scripts/shaders reference by name, not hex. Adding new colors later requires ADR update + GDD update + palette.md version bump.

## Key Files
- `CLAUDE.md` — session instructions (lightweight, points at GDD)
- `GDD.md` — **canonical design doc** (all game design decisions)
- `palette.md` — **canonical palette spec** (PixelLab enforcement, awakening-arc reveal rules)
- `notes.md` — current state, MCP status, credentials
- `ADR.md` — this file, architectural decisions
- `document_pdf.pdf` — original design session PDF (reference only)
- `.claude/settings.json` — legacy project MCP config (INERT — Claude Code reads from ~/.claude.json)
- `~/.claude.json` — actual MCP server config (user-level)
- `.gitattributes` — Git LFS patterns
- `godot_project/project.godot` — Godot project root

## Change Log
- 2026-04-16: Project scaffolded. All dependencies installed except Godot MCP Pro, PixelLab, Suno credentials.
- 2026-04-17: Session 002. MCP servers migrated to ~/.claude.json (project config was inert). Godot MCP Pro connected live. Drafted GDD v0.1 from design interview. Dystopian reframe (v0.2) — dual-register terminology, Reeducation Facility replaces school, custodians replace parents, minimap-with-fog locked. Palette v1.0 locked (`palette.md`). ADR-008 through ADR-012 added. Viewport updated to 640x360 in `project.godot`. Home68.tscn placeholder removed.
