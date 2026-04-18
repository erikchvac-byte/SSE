# Aseprite Workflow — SSE

Operating procedure for all tile and sprite work in Aseprite. Follows ADR-017 (asset pipeline split) and ADR-016 (asset review gate).

## When to use Aseprite

The pipeline splits by **asset shape**, not subject matter:

| Asset type | Tool | Why |
|---|---|---|
| Tileable textures (floors, walls, grass, repeating ground) | **Aseprite** | Palette-lock by default, tileable by construction |
| UI chrome (panels, HUD frames, buttons) | **Aseprite** | Pixel-precise, no generative drift |
| Character sprites (player, NPCs) | PixelLab → **Aseprite redraw** | PixelLab generates at 64×64, Aseprite redraws at 32×32 |
| Discrete props (bed, desk, door, sign, vehicle, tree, mailbox) | PixelLab → **Aseprite redraw** | Same 64×64 → 32×32 flow as characters |

World tiles go to Aseprite only. Discrete objects that live in the world (tree, fence post, car) are sprites, not tiles — those go through PixelLab → Aseprite redraw.

## One-time setup

### 1. Verify Aseprite is installed
Open Aseprite. Confirm version is 1.3+ (File → About).

### 2. Import the palette
Locked palette lives at `palette.md` (specification) and `palette.gpl` (Aseprite-importable file).

- Open Aseprite.
- Open the Palette panel (Window → Palette).
- Click the Options icon (hamburger menu) → **Load Palette…**
- Select `palette.gpl` from the repo root.
- The 10 named colors appear in the palette panel. Hover to confirm names match `palette.md` (sky_cool_highlight, acid_cream, warm_ochre, sage_lawn, deep_shadow, crt_green, amber_terminal, glitch_magenta, signal_purple, base_black).

### 3. Set Aseprite preferences
- Edit → Preferences → **Editor**: enable **Grid** with Width 32, Height 32. This draws a 32×32 guideline on tile canvases.
- Edit → Preferences → **Color Mode**: prefer **Indexed** for palette-locked work (prevents stray colors). RGB is acceptable if you manually verify only palette colors are used.

## Creating a new tile (Aseprite-only)

### 1. New file
- File → New
- Width 32, Height 32, Color Mode **Indexed**, Background **Transparent**
- At the color profile prompt, accept default (sRGB).

### 2. Load the palette
- Palette panel → Options → **Load Palette** → `palette.gpl`.
- Before drawing, confirm the active palette is SSE — not Aseprite's default.

### 3. Preview tiling
- View → **Tiled Mode → Tiled in Both Axes**
- The canvas now shows a 3×3 preview of the tile tiling itself. Seams between repeats are visible immediately.
- Draw against this preview. A tile that looks fine alone but has seams in tiled mode is broken.

### 4. Draw
- Use only palette colors. Environment tiles use the 5 environment + base black (per palette.md §2 rule 1). No UI colors on environment sprites.
- Per-tile color budget: 3–5 environment colors active (palette.md §2 rule 5).
- Avoid anti-aliasing and dithering — hard pixel edges only.

### 5. Export
- File → **Export As…** (not Save As)
- Filename pattern: `<category>_<descriptor>_<variant>.png` — e.g. `floor_carpet_beige.png`, `wall_drywall_cream.png`
- Destination: `assets/tiles/`
- Scale: 1x (native 32×32). Do not export at 2x or larger.
- Apply pixel ratio: **1:1**.

### 6. Commit
After user review (ADR-016 gate — visual authority is user):
- `git add assets/tiles/<filename>.png`
- `git commit -m "assets(tiles): <description>"`

## Redrawing a sprite from PixelLab 64×64 → 32×32

PixelLab generates sprites at 64×64 (ADR-017). You redraw at 32×32 in Aseprite, using the 64×64 as a reference.

### 1. Open the 64×64 source
The PixelLab output lands in `assets/_pending/` (ADR-016 staging). Open it in Aseprite: File → Open → select the `_pending/<name>_64.png`.

### 2. Create the 32×32 target
- File → New → 32×32, Indexed, Transparent background.
- Load palette (`palette.gpl`) if not already active.

### 3. Set up reference
Two ways — pick one:

**Option A — two-window view** (simplest): arrange the 64×64 source and the 32×32 target side-by-side. Draw on the 32×32 while looking at the 64×64.

**Option B — reference layer** (more precise): in the 32×32 file, Layer → **New Reference Layer…** → select the 64×64 PNG. Aseprite places it at reduced opacity above the canvas. Draw beneath on a regular layer. Delete the reference layer before export.

### 4. Redraw
- Reproduce silhouette, proportions, and palette-mapping from the 64×64, but at 32×32 precision.
- Every pixel is a decision at this scale — you will NOT get 4× the detail, you will get a simplified but cleaner version.
- Stay in the locked palette. Do not pick new colors from the PixelLab output — match to the nearest palette name.
- Character skin: warm_ochre mid-tone, acid_cream highlight, deep_shadow shadow (palette.md §4).

### 5. Export the final 32×32
- File → Export As… → filename `<subject>_<state>_<direction>.png` — e.g. `player_idle_south.png`, `bed_single_01.png`.
- Destination depends on subject:
  - Character: `assets/characters/`
  - Prop: `assets/props/` (create if not present — mkdir -p)
- Scale 1x, pixel ratio 1:1.

### 6. Archive the 64×64 source
Move the 64×64 PixelLab source from `_pending/` into the reference archive:
- Filename: same stem as the 32×32 final, but with `_64` suffix. E.g. `player_idle_south_64.png`.
- Destination: `assets/reference/sprites_64/`
- Shell command: `mv "assets/_pending/<original_name>_64.png" "assets/reference/sprites_64/<final_name>_64.png"`

**Why archive:** if a sprite needs re-drawing (style tweak, animation frames, NPC variant), the 64×64 source is the cheap way to iterate. Regenerating via PixelLab spends credits; redrawing from the archived 64×64 is free.

### 7. Commit both files
```
git add assets/characters/player_idle_south.png assets/reference/sprites_64/player_idle_south_64.png
git commit -m "assets(sprites): player idle south"
```

## Palette enforcement

- **Always** load `palette.gpl` before drawing. Default Aseprite palette is wrong.
- **Prefer Indexed color mode** for new work — stray colors become impossible. If using RGB, verify after drawing via palette histogram check (see below).
- The 10 colors are final. Do not add colors to the `.gpl` or pick from the image with the eyedropper unless that color is already palette-locked.

## Verification checklist (before moving from `_pending/` to final path)

- [ ] Dimensions match target (32×32 for all final assets)
- [ ] Palette histogram contains ONLY locked hex values (see Claude's mechanical check below)
- [ ] For tiles: 4-way tiled-mode preview shows no visible seams
- [ ] For sprites: readable silhouette at 32×32, consistent with the 64×64 source
- [ ] Filename follows the naming convention above
- [ ] No anti-aliasing, no dithering, no intermediate tones
- [ ] For environment sprites: no UI colors present
- [ ] For UI sprites: no environment colors present (palette.md §2 rules 1-3)

## Claude's role in this workflow

Claude does **not** visually review 32×32 assets (ADR-017 — reliability below ~64×64 is poor). Claude's review role is **mechanical**:

1. **Palette histogram check** — verify the PNG contains only the 10 locked hex values. Script (TBD): Python + Pillow, count unique colors, compare to palette.md §1 hex list. Exit 0 if clean, exit 1 with offending pixels listed.
2. **Dimension check** — final asset is exactly 32×32.
3. **Filename check** — matches naming convention.
4. **Staging-gate check** — asset came from `_pending/`, not generated straight to final.
5. **For sprites**: 64×64 source was archived to `assets/reference/sprites_64/`, not deleted.

Visual review — does it look right, is the silhouette clear, does it match the aesthetic — is **always your call**.

## File locations summary

| File | Path | Notes |
|---|---|---|
| Canonical palette spec | `palette.md` | Human-readable, authoritative |
| Aseprite palette file | `palette.gpl` | Imported by Aseprite Palette panel |
| Godot palette resource | `godot_project/resources/palette.tres` | Used in-engine; see ADR-015 |
| Tile assets (final) | `assets/tiles/` | 32×32, hand-drawn in Aseprite |
| Character sprites (final) | `assets/characters/` | 32×32, redrawn from 64×64 |
| Prop sprites (final) | `assets/props/` | 32×32, redrawn from 64×64 |
| 64×64 PixelLab sources | `assets/reference/sprites_64/` | Archived per ADR-017 |
| Pending review | `assets/_pending/` | Gitignored; transient; ADR-016 |

## Related ADRs

- **ADR-012** — 10-color palette system with set separation
- **ADR-015** — palette resource pattern + Phase 1 folder layout
- **ADR-016** — asset review gate via `assets/_pending/` staging
- **ADR-017** — asset pipeline split (this doc is the ADR-017 follow-up)
