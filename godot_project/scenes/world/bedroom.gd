@tool
extends Node2D

# Phase 1 bedroom scaffold. Placeholder rects painted from palette.tres —
# no PixelLab sprites yet. Swap the _draw() body for a TileMap + Sprite2D
# once tiles and furniture sprites are generated.

@export var palette: Palette
@export var room_tiles: Vector2i = Vector2i(12, 8)
@export var tile_size: int = 32

@onready var _player: YouthUnit = $YouthUnit
@onready var _minimap: Minimap = $UI/Minimap


func _ready() -> void:
	if palette == null:
		palette = load("res://resources/palette.tres") as Palette
	_build_walls()
	_player.moved.connect(_on_player_moved)
	_minimap.update_player_position(_player.global_position)
	queue_redraw()


func _on_player_moved(world_pos: Vector2) -> void:
	_minimap.update_player_position(world_pos)


# Single source of truth for wall geometry. Both _draw() and _build_walls()
# consume this, so the visual and the physics can never drift.
func _wall_rects() -> Array[Rect2]:
	var room_px := Vector2(room_tiles * tile_size)
	var door_w := float(tile_size * 2)
	var door_x := (room_px.x - door_w) / 2.0
	return [
		# Top edge, full width.
		Rect2(Vector2.ZERO, Vector2(room_px.x, tile_size)),
		# Left edge, between top and bottom walls.
		Rect2(Vector2(0, tile_size), Vector2(tile_size, room_px.y - 2 * tile_size)),
		# Right edge, between top and bottom walls.
		Rect2(
			Vector2(room_px.x - tile_size, tile_size),
			Vector2(tile_size, room_px.y - 2 * tile_size),
		),
		# Bottom edge, left of doorway.
		Rect2(Vector2(0, room_px.y - tile_size), Vector2(door_x, tile_size)),
		# Bottom edge, right of doorway.
		Rect2(
			Vector2(door_x + door_w, room_px.y - tile_size),
			Vector2(room_px.x - door_x - door_w, tile_size),
		),
	]


func _build_walls() -> void:
	for rect in _wall_rects():
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = rect.size
		shape.shape = rect_shape
		shape.position = rect.position + rect.size / 2.0
		body.add_child(shape)
		add_child(body)


func _draw() -> void:
	if palette == null:
		return
	var room_px := Vector2(room_tiles * tile_size)
	# Floor — acid_cream (the uncanny cheerful cream).
	draw_rect(Rect2(Vector2.ZERO, room_px), palette.acid_cream)
	# Walls — warm_ochre wood trim, same rects used for collision.
	for rect in _wall_rects():
		draw_rect(rect, palette.warm_ochre)
	# Bed placeholder — sage_lawn 3×2.
	draw_rect(
		Rect2(Vector2(2 * tile_size, 2 * tile_size), Vector2(3 * tile_size, 2 * tile_size)),
		palette.sage_lawn,
	)
	# Desk placeholder — deep_shadow 2×1.
	draw_rect(
		Rect2(Vector2(9 * tile_size, 2 * tile_size), Vector2(2 * tile_size, tile_size)),
		palette.deep_shadow,
	)
