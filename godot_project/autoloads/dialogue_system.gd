extends CanvasLayer

# Minimal dialogue PoC per GDD §11 open-gap. Displays register-appropriate
# text at the bottom of the screen and hides on dismiss. No queue, no
# next-page, no typewriter — register is chosen at show_dialogue() call
# time from the current self_awareness reading and does not live-update
# if awareness changes mid-line. A real dialogue system will supersede.

const INSTITUTIONAL_THRESHOLD := 51

@export var palette: Palette

var _panel: PanelContainer
var _label: Label

signal opened(surface_text: String, institutional_text: String)
signal dismissed


func _ready() -> void:
	if palette == null:
		palette = load("res://resources/palette.tres") as Palette
	layer = 10
	_build_layout()
	visible = false


func _build_layout() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 16
	_panel.offset_right = -16
	_panel.offset_top = -64
	_panel.offset_bottom = -16
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)


func show_dialogue(surface_text: String, institutional_text: String = "") -> void:
	var resolved_institutional := institutional_text if institutional_text != "" else surface_text
	var use_inst := _awareness_level() >= INSTITUTIONAL_THRESHOLD and institutional_text != ""
	_label.text = resolved_institutional if use_inst else surface_text
	_apply_palette(use_inst)
	visible = true
	opened.emit(surface_text, resolved_institutional)


func hide_dialogue() -> void:
	if not visible:
		return
	visible = false
	dismissed.emit()


func is_open() -> bool:
	return visible


func _apply_palette(use_inst: bool) -> void:
	if palette == null:
		return
	var text_color: Color
	var bg_color: Color
	if use_inst:
		text_color = palette.crt_green
		bg_color = palette.base_black
	else:
		text_color = palette.deep_shadow
		bg_color = palette.acid_cream
	_label.add_theme_color_override("font_color", text_color)
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	_panel.add_theme_stylebox_override("panel", style)


func _awareness_level() -> int:
	var player_state := get_node_or_null("/root/PlayerState")
	if player_state == null or player_state.stats == null:
		return 0
	return player_state.stats.self_awareness
