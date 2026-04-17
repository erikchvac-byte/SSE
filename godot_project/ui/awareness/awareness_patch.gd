class_name AwarenessPatch
extends Node2D

# Minimal palette-colored rect useful as a demo/placeholder for
# "this detail only appears when the player is awake enough to see
# it." Put it under an AwarenessGated parent to get the gating for
# free. Size and color are picked from the canonical Palette so we
# never hardcode hex in UI code.

@export var palette: Palette
@export var color_name: String = "signal_purple"
@export var size: Vector2 = Vector2(16, 16)


func _ready() -> void:
	if palette == null:
		palette = load("res://resources/palette.tres") as Palette
	queue_redraw()


func _draw() -> void:
	if palette == null:
		return
	var color: Color = palette.get(color_name)
	draw_rect(Rect2(-size / 2.0, size), color)
