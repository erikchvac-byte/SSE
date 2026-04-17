# Palette Spec — Untitled 90s Suburban Sim

**Version**: 1.0 — locked 2026-04-17
**Philosophy**: Hyperreal-uncanny 1997 suburb + institutional 1997 computer UI. Hard separation between world-facing and system-facing color sets. The separation itself is the game's core visual mechanic.

Canonical. `GDD.md` §2 references this file. All PixelLab prompts must enforce it.

---

## 1. Color Sets

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

## 2. Rules

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

## 3. Awakening Arc — Color as Wake-Up Meter

Per GDD §5.2 and §6, the `self_awareness` stat controls how much of the institutional layer is visible. Palette implementation:

| Self-awareness | Visible colors |
|---|---|
| 0–25 (fully normalized) | ENVIRONMENT only. UI text uses `#2D2A32` (shadow) on `#E6C547` (cream) — just "paperwork." No UI set active. |
| 26–50 (cracks appearing) | Occasional BRIDGE `#6A00FF` flashes on institutional objects (intercoms, seals, signs). UI set not yet visible. |
| 51–75 (awakening) | UI colors begin appearing on in-world signage, HUD, paperwork text. CRT green `#33FF66` for official readouts, amber `#FFB000` for warnings. |
| 76–100 (fully awake) | Full UI set visible. Magenta `#FF2BD6` alarms become detectable. Dual-register vocabulary (§3 of GDD) fully shown. |

This is the single most important rule in the spec: **raising self-awareness = more UI colors become visible to the player's view, even though they were mechanically always there.**

---

## 4. Skin / Character Notes

Characters are environment sprites. Skin tones use:
- Warm mid-tone: `#A87E4D`
- Light/highlight: `#E6C547`
- Shadow: `#2D2A32`

Range is intentionally narrow to keep character sprites cohesive with world sprites. Varied ethnicity can be expressed through combinations of the 5 environment colors + clothing/accessories rather than expanding the palette.

---

## 5. PixelLab Prompt Template

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

## 6. Godot Implementation Notes

- Store the 10 colors in a Godot resource (e.g., `res://resources/palette.tres`) as named `Color` exports so scripts and shaders can reference by name, not hex.
- Minimap, HUD, and any programmatic color use must pull from this resource. Never hard-code hex in script.
- Shader approach for the awakening arc: a post-process shader that gates which UI colors are visible based on `self_awareness`. Sprites are painted with the full palette; the shader hides/reveals.

---

## 7. Change Log

- **2026-04-17 — v1.0**: Locked from design session. User proposed original 10-color system with env/ui/bridge/base rules; hex values retuned for hyperreal-uncanny feel (env) + 1997-computer feel with one "glitch" color (ui). BRIDGE `#6A00FF` and GLOBAL BASE `#0B0B0F` preserved from original proposal.
