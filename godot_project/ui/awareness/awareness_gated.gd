class_name AwarenessGated
extends Node2D

# Container that hides itself (and therefore all descendants) when
# the player's self_awareness stat is below min_awareness. Registers
# with AwarenessController on _ready so broadcasts flow through.
# Place gated content (signs, insignia, bridge-color accents) as
# children of this node.

# Kept in sync with AwarenessController.GROUP. Hardcoded here so this
# script doesn't depend on cross-autoload parser resolution.
const GROUP := "awareness_gated"

@export var min_awareness: int = 26


func _ready() -> void:
	add_to_group(GROUP)
	var controller := get_node_or_null("/root/AwarenessController")
	if controller != null and controller.has_method("current_level"):
		apply_awareness(controller.current_level())
	else:
		apply_awareness(0)


func apply_awareness(level: int) -> void:
	visible = level >= min_awareness
