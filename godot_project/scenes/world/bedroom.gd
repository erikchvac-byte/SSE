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
	_player.moved.connect(_on_player_moved)
	_minimap.update_player_position(_player.global_position)
	queue_redraw()


func _on_player_moved(world_pos: Vector2) -> void:
	_minimap.update_player_position(world_pos)


func _draw() -> void:
	if palette == null:
		return
	var room_px := Vector2(room_tiles * tile_size)
	# Floor — acid_cream (the uncanny cheerful cream).
	draw_rect(Rect2(Vector2.ZERO, room_px), palette.acid_cream)
	# Wall perimeter — warm_ochre wood trim. Top, left, right.
	draw_rect(Rect2(Vector2.ZERO, Vector2(room_px.x, tile_size)), palette.warm_ochre)
	draw_rect(Rect2(Vector2.ZERO, Vector2(tile_size, room_px.y)), palette.warm_ochre)
	draw_rect(
		Rect2(Vector2(room_px.x - tile_size, 0), Vector2(tile_size, room_px.y)),
		palette.warm_ochre,
	)
	# Bottom wall with a 2-tile doorway in the middle.
	var door_w := float(tile_size * 2)
	var door_x := (room_px.x - door_w) / 2.0
	draw_rect(
		Rect2(Vector2(0, room_px.y - tile_size), Vector2(door_x, tile_size)),
		palette.warm_ochre,
	)
	draw_rect(
		Rect2(
			Vector2(door_x + door_w, room_px.y - tile_size),
			Vector2(room_px.x - door_x - door_w, tile_size),
		),
		palette.warm_ochre,
	)
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
