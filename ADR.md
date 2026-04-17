# Architecture Decision Record — Untitled 90s Suburban Sim

## Overview
2D top-down sandbox game set in 1997–2000 suburban America. Built in Godot 4.6.2.
Claude Code orchestrates all build actions through MCP tools. Human-in-the-loop pipeline
where every request is decomposed into atomic MCP-executable tasks before execution.

**This file is immutable.** Each ADR below is a frozen record of a decision at a point in time.
To change a decision, append a new ADR that supersedes the old — do not edit prior entries.
Current state lives in `notes.md`. Open work lives in GitHub Issues.

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

## ADR-004: Shared Project Schema for Asset Consistency
**Status**: Superseded by ADR-012
**Date**: 2026-04-16
**Context**: PixelLab generates non-deterministic outputs. Without locked parameters, art style will diverge across sessions.
**Decision**: All asset generation calls use locked config from `project_schema.json` (palette, pixel scale, tile size, style prefix).
**Rationale**: Ensures visual coherence across all AI-generated assets across sessions and tools.
**Consequences**: Requires discipline to always reference schema before calling PixelLab. Schema changes require retroactive asset updates.
**Note**: `project_schema.json` was not created. Canonical asset config now lives in `palette.md` and `GDD.md` per ADR-012.

## ADR-005: Audio Pipeline with FFmpeg Fallback
**Status**: Superseded by change log entry 2026-04-17 (MCP Audio Tweaker removed; FFmpeg authoritative)
**Date**: 2026-04-16
**Context**: Suno outputs MP3. Godot requires OGG (streaming music) and WAV (sfx). MCP Audio Tweaker handles conversion but is pre-release.
**Decision**: Primary path = MCP Audio Tweaker. Fallback = direct FFmpeg call. FFmpeg is authoritative.
**Rationale**: MCP Audio Tweaker is convenient but experimental. FFmpeg is stable and already installed.
**Consequences**: Must verify MCP Audio Tweaker on each session before relying on it. Always have FFmpeg command ready.

## ADR-006: Git LFS for Binary Assets
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Sprites, audio, and Godot binary files will bloat standard Git history rapidly.
**Decision**: Git LFS for all binary asset types (see `.gitattributes`).
**Rationale**: Keeps repo size manageable, standard practice for game projects.
**Consequences**: Requires Git LFS initialized on all contributor machines. LFS bandwidth costs on GitHub for large projects.

## ADR-007: Tiled Map Editor for Level Layout
**Status**: Accepted
**Date**: 2026-04-16
**Context**: Structural level layout benefits from a dedicated visual tool. Godot's built-in tilemap editor is sufficient but Tiled offers better workflow for large world design.
**Decision**: Tiled for structural layout only. Exports as `.tmj`. Godot Tiled Importer bridges to Godot.
**Rationale**: Tiled provides superior world-building UX for large maps. `.tmj` (JSON) format is human-readable and git-diffable.
**Consequences**: Requires Godot Tiled Importer plugin installed and configured. Tile size and layer naming must match schema exactly.

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

## ADR-013: Records Discipline (Three-File System)
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Stale "Pending", "Known Issues", and "Open Questions" sections were accumulating across `notes.md`, `ADR.md`, and Obsidian index files. Resolved items weren't being deleted, creating confusion about what was currently true.
**Decision**: Strict separation of concerns. `notes.md` = current state (mutable, items deleted when no longer true). `ADR.md` = decisions (immutable; supersede, don't edit). `Sessions/*.md` in the Obsidian vault = behavioral log (append-only). GitHub Issues = open work. Each concern has exactly one home.
**Rationale**: Mixing current state, history, and open work in the same file forces readers to guess what's still valid. Separating by mutability (immutable decisions, mutable state, append-only log, external issues) eliminates the ambiguity.
**Consequences**: `ADR.md` loses its "Testing Results", "Known Issues", "Open Questions", and "Future Considerations" sections — that content moves to `notes.md` (if current) or GitHub Issues (if open work). Every session must prune `notes.md` rather than annotate. Changing a decision requires writing a new ADR.

## ADR-014: Secret Scrubbing via git filter-repo Before First Push
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Commit `960fa44` wrote live GitHub PAT and PixelLab API key into `.claude/settings.json` and was baked into local history. First push was imminent; publishing as-is would have leaked both.
**Decision**: Use `git filter-repo --replace-text` to rewrite history, scrubbing the two secret strings across all commits that contained them. Repo had no remote yet, so destructive SHA rewrites had no downstream cost.
**Rationale**: `git filter-repo` is the modern, supported tool (filter-branch is deprecated). Surgical string replacement preserves commit structure and messages; only the leaked substrings change to `REDACTED_*` placeholders.
**Consequences**: Commit SHAs `960fa44`, `b2fcf07`, `8a13c2a` were rewritten to `e843c95`, `9a2642d`, `b1d63ed`. Any future secret exposure before push follows the same protocol. Post-push exposure requires key rotation + `git filter-repo` + `git push --force`, which must be coordinated with all clones.

## ADR-015: Palette Resource Pattern + Phase 1 Asset Organization
**Status**: Accepted
**Date**: 2026-04-17
**Context**: Needed a concrete way to expose the 10-color palette (ADR-012) to every script, shader, and scene without hardcoding hex values. Also needed a consistent folder layout before the first scene was written, so later sessions don't fragment asset locations.
**Decision**: (1) `Palette` is a `class_name` GDScript resource at `res://resources/palette.gd` with typed `@export var <name>: Color` properties matching `palette.md` §1 names (sky_cool_highlight, acid_cream, warm_ochre, sage_lawn, deep_shadow, crt_green, amber_terminal, glitch_magenta, signal_purple, base_black). Canonical instance at `res://resources/palette.tres`. Scenes reference it through an `@export var palette: Palette` slot wired to the .tres. Scripts load it via `load("res://resources/palette.tres") as Palette` when no injection is available. (2) Awakening-arc visibility gating (ADR-011) lives on the Palette resource as `visible_for_awareness(self_awareness: int) -> Dictionary` so shaders and UI query the palette itself, not a separate gate layer. (3) Phase 1 folder layout: `res://resources/` (data resources), `res://ui/<feature>/` (UI scenes + scripts — e.g. `ui/minimap/`), `res://scenes/<category>/` where category is `player`, `world`, `npc`, etc.
**Rationale**: Typed `@export` Colors catch typos at parse time instead of runtime. The .tres being authoritative lets future palette variants (degraded compound, nightmare-tier) swap in without touching code. Putting the visibility gate on the resource keeps the awakening-arc logic in one place and testable in isolation. Flat per-feature UI folders scale without a separate `scripts/` tree drifting from its scene.
**Consequences**: Every new script that needs a color must go through a `Palette` reference — greppable rule, enforceable in review. Adding a palette color requires updating `palette.gd` defaults, `palette.tres`, `palette.md`, and likely `visible_for_awareness` thresholds. No `res://scripts/` directory; scripts live beside their scenes.

## Technical Constraints
- Godot 4.4+ required (Godot MCP Pro hard requirement).
- Node.js 18+ required (Godot MCP Pro server).
- Godot editor must be open for any Godot MCP Pro calls.
- All pixel art: 32x32px tiles, locked palette (ADR-012).
- Audio: OGG for music, WAV for sfx, -14 LUFS normalized.

## Key Files
- `CLAUDE.md` — session instructions (lightweight, points at GDD)
- `GDD.md` — **canonical design doc** (all game design decisions)
- `palette.md` — **canonical palette spec** (PixelLab enforcement, awakening-arc reveal rules)
- `notes.md` — current state (mutable)
- `ADR.md` — this file, immutable decisions
- `.claude/settings.json` — project permissions only (no MCPs, no secrets)
- `~/.claude.json` — user-level MCP config (outside repo)
- `.gitattributes` — Git LFS patterns
- `godot_project/project.godot` — Godot project root

## Change Log
- 2026-04-16: Project scaffolded. ADR-001 through ADR-007 recorded.
- 2026-04-17 (Session 002): MCPs migrated to `~/.claude.json` (project config was inert). Godot MCP Pro connected live. GDD v0.1 → v0.2 dystopian reframe. Palette v1.0 locked. ADR-008 through ADR-012 added. Viewport updated to 640×360 in `project.godot`. Home68.tscn placeholder removed.
- 2026-04-17 (Session 003): First GitHub push to `erikchvac-byte/SSE` (public). Leaked secrets scrubbed from history via `git filter-repo` (ADR-014). `.claude/settings.json` `mcpServers` block removed. GitHub MCP registered in `~/.claude.json`. Records discipline adopted (ADR-013). ADR-004 marked superseded by ADR-012. ADR-005 note appended (MCP Audio Tweaker removed).
- 2026-04-17 (Session 004): First code pass. Palette resource + script (ADR-015). Minimap UI skeleton (always-on, fog-of-war, top-right, palette-driven). Bedroom scaffold scene with placeholder rects + player CharacterBody2D + minimap instance wired via moved signal. 4 unique NPCs designed (GDD §9.1.1, v0.2.2). GitHub issues #5/#6/#7/#8 closed. Autonomous-work allowlist expanded in `.claude/settings.local.json` (filesystem MCP + godot-mcp-pro non-runtime ops).
