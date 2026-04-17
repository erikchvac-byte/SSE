class_name Minimap
extends Control

# Always-on fog-of-war minimap per GDD §10.
# Phase 1 skeleton: no art yet, no real world grid yet. Call
# update_player_position(world_pos) each frame once the player scene exists.

@export var palette: Palette
# How many world tiles the minimap can cover. 1 tile = 1 minimap pixel.
@export var world_tiles: Vector2i = Vector2i(64, 64)
# Size of one world tile in world pixels (matches GDD: 32).
@export var source_tile_size: int = 32
# Tiles revealed in a radius around the player each step.
@export var reveal_radius: int = 3

var _explored: Dictionary = {} # Vector2i -> bool
var _player_tile: Vector2i = Vector2i.ZERO
var _player_tile_valid: bool = false


func _ready() -> void:
	if palette == null:
		palette = load("res://resources/palette.tres") as Palette
	custom_minimum_size = Vector2(world_tiles)
	queue_redraw()


func update_player_position(world_pos: Vector2) -> void:
	# Vector2i(Vector2) truncates toward zero; the float divide + cast
	# keeps the math readable and avoids GDScript's integer-division warning.
	var tile := Vector2i(world_pos / float(source_tile_size))
	var moved := not _player_tile_valid or tile != _player_tile
	var newly_revealed := not _explored.has(tile)
	_player_tile = tile
	_player_tile_valid = true
	if moved or newly_revealed:
		_reveal_around(tile, reveal_radius)
		queue_redraw()


func _reveal_around(center: Vector2i, radius: int) -> void:
	var r_squared := radius * radius
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if dx * dx + dy * dy > r_squared:
				continue
			var t := Vector2i(center.x + dx, center.y + dy)
			if t.x < 0 or t.y < 0 or t.x >= world_tiles.x or t.y >= world_tiles.y:
				continue
			_explored[t] = true


func _draw() -> void:
	if palette == null:
		return
	# Unexplored: base_black fog.
	draw_rect(Rect2(Vector2.ZERO, Vector2(world_tiles)), palette.base_black)
	# Explored: deep_shadow (environment color, visible at awareness 0).
	for tile in _explored:
		draw_rect(Rect2(Vector2(tile.x, tile.y), Vector2.ONE), palette.deep_shadow)
	# Player "you are here": sage_lawn single-tile blip.
	if _player_tile_valid:
		draw_rect(
			Rect2(Vector2(_player_tile.x, _player_tile.y), Vector2.ONE),
			palette.sage_lawn,
		)
