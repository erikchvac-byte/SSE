class_name Interactable
extends Area2D

# Area2D that fires a DialogueSystem line when the player overlaps and
# presses E. PoC — future interactables will carry richer payloads
# (item pickup, state change, multi-step flow) beyond just dialogue.
#
# Collision: layer 4 (interactables), mask 2 (characters). Player is
# expected on layer 2. If overlap doesn't trigger, check the layer
# label mapping in project.godot [layer_names] and player.tscn.

@export var surface_text: String = ""
@export var institutional_text: String = ""

var _player_overlap: bool = false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_overlap:
		return
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode != KEY_E:
		return
	var ds := get_node_or_null("/root/DialogueSystem")
	if ds == null:
		return
	if ds.is_open():
		ds.hide_dialogue()
	else:
		ds.show_dialogue(surface_text, institutional_text)


func _on_body_entered(body: Node2D) -> void:
	if body is YouthUnit:
		_player_overlap = true


func _on_body_exited(body: Node2D) -> void:
	if body is YouthUnit:
		_player_overlap = false
		var ds := get_node_or_null("/root/DialogueSystem")
		if ds and ds.is_open():
			ds.hide_dialogue()
