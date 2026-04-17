class_name YouthUnit
extends CharacterBody2D

# Placeholder player. No sprite yet — draws a palette-colored rect via
# _draw() so the bedroom scaffold is visible without PixelLab spend.
# Replace _draw() body with an AnimatedSprite2D once the walk cycle is generated.

@export var palette: Palette
@export var speed: float = 80.0
@export var sprite_size: int = 24

signal moved(world_pos: Vector2)

@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	if palette == null:
		palette = load("res://resources/palette.tres") as Palette
	_camera.make_current()
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down"),
	)
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	if velocity != Vector2.ZERO:
		moved.emit(global_position)


func _draw() -> void:
	if palette == null:
		return
	var half := sprite_size / 2.0
	var rect := Rect2(Vector2(-half, -half), Vector2(sprite_size, sprite_size))
	draw_rect(rect, palette.warm_ochre)
	draw_rect(rect, palette.deep_shadow, false, 1.0)
