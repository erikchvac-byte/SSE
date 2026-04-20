# Palette Spec — Untitled 90s Suburban Sim

**Version**: 1.1 — extensible (per ADR-018, 2026-04-19)
**Philosophy**: Hyperreal-uncanny 1997 suburb + institutional 1997 computer UI. Hard separation between world-facing and system-facing color sets. The separation itself is the game's core visual mechanic. The **core 10 colors** below are canonical and govern PixelLab generation and the awakening-arc reveal mechanic. Extended color sets (§2 onwards) are back-registered from hand-drawn tile work and are not constrained by ENV/UI/BRIDGE rules.

Canonical. `GDD.md` §2 references this file. All PixelLab prompts must enforce it.

---

## 1. Core Color Sets (canonical — PixelLab enforcement + awakening arc)

### ENVIRONMENT (5 colors, world-facing)

| Hex | Role | Notes |
|---|---|---|
| `#8FD4E8` | Sky / cool highlight | Slightly too cyan. Sky, pool water, TV glow. Never institutional. |
| `#E6C547` | Acid cream | Siding, interior walls, warm sunlight. Cream that's slightly too vivid. |
| `#A87E4D` | Warm ochre | Wood, brick, roofs, fences, doors, skin mid-tones. Grounds the palette. |
| `#6B8B58` | Sage lawn | Grass, hedges, leaves, indoor plants. Sage that's slightly dusty. |
| `#2D2A32` | Deep shadow | Near-black. Shadows, tree silhouettes, outlines, dark clothing. |

### UI (3 colors, system-facing)

| Hex | Role | Notes |
|---|---|---|
| `#33FF66` | CRT phosphor green | HUD text, terminal screens, official readouts. 1997-era monitor vibes. |
| `#FFB000` | Amber terminal | Warnings, secondary HUD, status indicators. Old-display amber. |
| `#FF2BD6` | Glitch magenta | The "wrong" color. Alarms, flags, signifiers of the dystopian layer breaking through. |

### BRIDGE (1 color, both sets)

| Hex | Role | Notes |
|---|---|---|
| `#6A00FF` | Signal purple | Institutional insignia, seals, PA-system glow, things the player learns to fear. Allowed in either set. |

### GLOBAL BASE (1 color, always present)

| Hex | Role | Notes |
|---|---|---|
| `#0B0B0F` | Base black | Background, void, negative space. Present in every screen. |

---

---

## 2. Extended Color Sets

Extended sets are registered from hand-drawn tile assets. They are not governed by the ENV/UI/BRIDGE rules and are not injected into PixelLab prompts. Colors added as more tile work is done — each extension gets an origin note and a palette.md version bump.

### INTERIOR BEDROOM SET (31 colors — v1.1, 2026-04-19)
Source: `InteriorTilesLITE_edited-export.png`. 80 raw colors collapsed to 31 by snapping ±2-channel noise clusters to their most-used representative.

| Hex | Name | Family |
|---|---|---|
| `#452E40` | int_mauve_01 | mauve |
| `#4D2B44` | int_mauve_02 | mauve |
| `#5C454F` | int_mauve_03 | mauve |
| `#693947` | int_mauve_04 | mauve |
| `#7A3B4E` | int_warm_01 | warm |
| `#7B6268` | int_warm_02 | warm |
| `#8F5152` | int_warm_03 | warm |
| `#A84B55` | int_warm_04 | warm |
| `#AB597D` | int_warm_05 | warm |
| `#9C807D` | int_warm_06 | warm |
| `#B77E6B` | int_warm_07 | warm |
| `#D8715E` | int_warm_08 | warm |
| `#C47F78` | int_warm_09 | warm |
| `#D3A083` | int_warm_10 | warm |
| `#C3A79C` | int_warm_11 | warm |
| `#F09F70` | int_warm_12 | warm |
| `#EBC8A8` | int_warm_13 | warm |
| `#F7CF91` | int_rose_01 | rose-light |
| `#DBC9B3` | int_rose_02 | rose-light |
| `#FCECD2` | int_rose_03 | rose-light |
| `#64B082` | int_green_01 | green |
| `#AAD796` | int_green_02 | green |
| `#A0DED3` | int_green_03 | green |
| `#488985` | int_teal_01 | teal |
| `#6FB0B6` | int_teal_02 | teal |
| `#3E3B66` | int_blue_01 | blue |
| `#3F5B73` | int_blue_02 | blue |
| `#4A5686` | int_blue_03 | blue |
| `#577E9D` | int_blue_04 | blue |
| `#2C1E2F` | int_purple_01 | purple |
| `#392944` | int_purple_02 | purple |

---

## 3. Rules

1. **Environment uses only ENVIRONMENT colors** (plus BRIDGE and GLOBAL BASE).
2. **UI uses only UI colors** (plus BRIDGE and GLOBAL BASE).
3. **Never mix ENVIRONMENT and UI colors directly** in the same sprite/element.
4. **Interaction exception**: An environment object being interacted with may be overlaid with a UI color (e.g., a door glows `#33FF66` when the player's prompt appears). The overlay is a SEPARATE visual layer, not a recolor of the underlying sprite.
5. **Per-screen budget**:
   - 3–5 ENVIRONMENT colors active
   - 1–2 UI colors active
   - BRIDGE: 0 or 1 (rare — reserve for system moments)
   - GLOBAL BASE: always present
6. **Black is not a color choice.** Use `#2D2A32` (environment shadow) or `#0B0B0F` (global base). Never pure `#000000`.

---

## 4. Awakening Arc — Color as Wake-Up Meter

Per GDD §5.2 and §6, the `self_awareness` stat controls how much of the institutional layer is visible. Palette implementation:

| Self-awareness | Visible colors |
|---|---|
| 0–25 (fully normalized) | ENVIRONMENT only. UI text uses `#2D2A32` (shadow) on `#E6C547` (cream) — just "paperwork." No UI set active. |
| 26–50 (cracks appearing) | Occasional BRIDGE `#6A00FF` flashes on institutional objects (intercoms, seals, signs). UI set not yet visible. |
| 51–75 (awakening) | UI colors begin appearing on in-world signage, HUD, paperwork text. CRT green `#33FF66` for official readouts, amber `#FFB000` for warnings. |
| 76–100 (fully awake) | Full UI set visible. Magenta `#FF2BD6` alarms become detectable. Dual-register vocabulary (§3 of GDD) fully shown. |

This is the single most important rule in the spec: **raising self-awareness = more UI colors become visible to the player's view, even though they were mechanically always there.**

---

## 5. Skin / Character Notes

Characters are environment sprites. Skin tones use:
- Warm mid-tone: `#A87E4D`
- Light/highlight: `#E6C547`
- Shadow: `#2D2A32`

Range is intentionally narrow to keep character sprites cohesive with world sprites. Varied ethnicity can be expressed through combinations of the 5 environment colors + clothing/accessories rather than expanding the palette.

---

## 6. PixelLab Prompt Template

Every PixelLab call must include this enforcement block in the prompt:

```
PALETTE LOCK:
Use ONLY these hex colors, no others:
#8FD4E8 (sky blue), #E6C547 (acid cream), #A87E4D (warm ochre),
#6B8B58 (sage), #2D2A32 (deep shadow), #0B0B0F (base black).
No anti-aliasing, no dithering, no intermediate tones.
Hard pixel edges. 32x32 native resolution. Stardew Valley readability.
Style: late-1990s American suburb, slightly hyperreal, uncanny.
```

For UI / institutional sprites only, swap palette lock to UI set:

```
PALETTE LOCK:
Use ONLY these hex colors, no others:
#33FF66 (CRT green), #FFB000 (amber), #FF2BD6 (glitch magenta),
#6A00FF (signal purple), #0B0B0F (base black).
No anti-aliasing. Hard pixel edges. 1997 CRT monitor aesthetic.
```

Bridge sprites (authority insignia, institutional signage) use:

```
PALETTE LOCK:
Primary: #6A00FF (signal purple), #2D2A32 (deep shadow), #0B0B0F (base black).
May also include: #E6C547 (cream) for paper, #33FF66 (CRT green) for text.
No anti-aliasing. 1997 institutional graphic design.
```

---

## 7. Godot Implementation Notes

- Store the 10 colors in a Godot resource (e.g., `res://resources/palette.tres`) as named `Color` exports so scripts and shaders can reference by name, not hex.
- Minimap, HUD, and any programmatic color use must pull from this resource. Never hard-code hex in script.
- Shader approach for the awakening arc: a post-process shader that gates which UI colors are visible based on `self_awareness`. Sprites are painted with the full palette; the shader hides/reveals.

---

## 8. Change Log

- **2026-04-17 — v1.0**: Locked from design session. User proposed original 10-color system with env/ui/bridge/base rules; hex values retuned for hyperreal-uncanny feel (env) + 1997-computer feel with one "glitch" color (ui). BRIDGE `#6A00FF` and GLOBAL BASE `#0B0B0F` preserved from original proposal.
- **2026-04-19 — v1.1**: Palette becomes extensible (ADR-018 supersedes ADR-012). Core 10 colors and all their rules unchanged. Interior bedroom set (31 colors) back-registered from hand-drawn tileset `InteriorTilesLITE_edited-export.png`. 80 raw colors collapsed to 31 by snapping ±2-channel noise clusters to most-used representative.
