class_name Palette
extends Resource

# Canonical palette v1.0 — see palette.md at repo root.
# Values on the .tres are authoritative. Defaults here match palette.md
# so a freshly-instanced Palette without a .tres still reads correctly.

# --- ENVIRONMENT (5 colors, world-facing) ---
@export var sky_cool_highlight: Color = Color("8FD4E8")
@export var acid_cream: Color = Color("E6C547")
@export var warm_ochre: Color = Color("A87E4D")
@export var sage_lawn: Color = Color("6B8B58")
@export var deep_shadow: Color = Color("2D2A32")

# --- UI (3 colors, system-facing) ---
@export var crt_green: Color = Color("33FF66")
@export var amber_terminal: Color = Color("FFB000")
@export var glitch_magenta: Color = Color("FF2BD6")

# --- BRIDGE (1 color, either set) ---
@export var signal_purple: Color = Color("6A00FF")

# --- GLOBAL BASE (1 color, always present) ---
@export var base_black: Color = Color("0B0B0F")


func environment_set() -> Array[Color]:
	return [sky_cool_highlight, acid_cream, warm_ochre, sage_lawn, deep_shadow]


func ui_set() -> Array[Color]:
	return [crt_green, amber_terminal, glitch_magenta]


# Awakening-arc visibility gate (palette.md §3).
# Returns the subset of the palette the player is allowed to see given
# their current self_awareness stat. Shaders and UI code should filter
# through this rather than reading colors directly.
func visible_for_awareness(self_awareness: int) -> Dictionary:
	var visible: Dictionary = {
		"base_black": base_black,
		"sky_cool_highlight": sky_cool_highlight,
		"acid_cream": acid_cream,
		"warm_ochre": warm_ochre,
		"sage_lawn": sage_lawn,
		"deep_shadow": deep_shadow,
	}
	if self_awareness >= 26:
		visible["signal_purple"] = signal_purple
	if self_awareness >= 51:
		visible["crt_green"] = crt_green
		visible["amber_terminal"] = amber_terminal
	if self_awareness >= 76:
		visible["glitch_magenta"] = glitch_magenta
	return visible
