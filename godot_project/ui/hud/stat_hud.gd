class_name StatHUD
extends Control

# Stat HUD per GDD §5.2 ("all stats 0-100, fully visible") wired into
# the awakening-arc reveal (palette.md §3, GDD §3). Below the
# institutional threshold the HUD reads as a kid's report card;
# at/above it the HUD reframes itself as a compliance readout.

const INSTITUTIONAL_THRESHOLD := 51

# Surface vs institutional labels per GDD §3 terminology table.
const LABELS_SURFACE := {
	"authenticity": "Authenticity",
	"alienation": "Alienation",
	"social_capital": "Friends",
	"scrip": "Money",
	"independence": "Independence",
	"self_awareness": "Awareness",
}

const LABELS_INSTITUTIONAL := {
	"authenticity": "Authenticity Index",
	"alienation": "Isolation Variance",
	"social_capital": "Compliance Standing",
	"scrip": "Scrip",
	"independence": "Autonomy Variance",
	"self_awareness": "Perceptual Clarity",
}

@export var palette: Palette

var _rows: Dictionary = {}  # stat_name -> {"name": Label, "value": Label}
var _background: ColorRect
var _using_institutional: bool = false


func _ready() -> void:
	if palette == null:
		palette = load("res://resources/palette.tres") as Palette
	mouse_filter = MOUSE_FILTER_IGNORE
	_build_layout()
	_connect_signals()
	_refresh_all()


func _connect_signals() -> void:
	var player_state := get_node_or_null("/root/PlayerState")
	if player_state and player_state.has_signal("stats_changed"):
		player_state.stats_changed.connect(_on_stats_changed)
	var awareness := get_node_or_null("/root/AwarenessController")
	if awareness and awareness.has_signal("level_changed"):
		awareness.level_changed.connect(_on_awareness_changed)


func _build_layout() -> void:
	_background = ColorRect.new()
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_background)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 6
	vbox.offset_top = 6
	vbox.offset_right = -6
	vbox.offset_bottom = -6
	vbox.mouse_filter = MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	add_child(vbox)

	for stat_name in YouthUnitStats.STAT_NAMES:
		var row := HBoxContainer.new()
		row.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 8)

		var name_label := Label.new()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value_label)

		vbox.add_child(row)
		_rows[stat_name] = {
			"name": name_label,
			"value": value_label,
		}


func _refresh_all() -> void:
	var level := _read_awareness_level()
	_using_institutional = level >= INSTITUTIONAL_THRESHOLD
	for stat_name in YouthUnitStats.STAT_NAMES:
		_refresh_row(stat_name)
	_apply_palette()


func _refresh_row(stat_name: String) -> void:
	if not _rows.has(stat_name):
		return
	var player_state := get_node_or_null("/root/PlayerState")
	if player_state == null or player_state.stats == null:
		return
	var label_dict: Dictionary = LABELS_INSTITUTIONAL if _using_institutional else LABELS_SURFACE
	var name_label: Label = _rows[stat_name]["name"]
	var value_label: Label = _rows[stat_name]["value"]
	name_label.text = label_dict[stat_name]
	value_label.text = str(player_state.stats.get_stat(stat_name))


func _apply_palette() -> void:
	if palette == null:
		return
	var text_color: Color
	var bg_color: Color
	if _using_institutional:
		text_color = palette.crt_green
		bg_color = palette.base_black
	else:
		text_color = palette.deep_shadow
		bg_color = palette.acid_cream
	_background.color = bg_color
	for stat_name in _rows:
		var name_label: Label = _rows[stat_name]["name"]
		var value_label: Label = _rows[stat_name]["value"]
		name_label.add_theme_color_override("font_color", text_color)
		value_label.add_theme_color_override("font_color", text_color)


func _read_awareness_level() -> int:
	var player_state := get_node_or_null("/root/PlayerState")
	if player_state == null or player_state.stats == null:
		return 0
	return player_state.stats.self_awareness


func _on_stats_changed(stat_name: String, _new_value: int) -> void:
	_refresh_row(stat_name)


func _on_awareness_changed(level: int) -> void:
	var should_use := level >= INSTITUTIONAL_THRESHOLD
	if should_use == _using_institutional:
		return
	_using_institutional = should_use
	for stat_name in YouthUnitStats.STAT_NAMES:
		_refresh_row(stat_name)
	_apply_palette()
