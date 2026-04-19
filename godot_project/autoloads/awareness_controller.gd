extends Node

# Autoload. Broadcasts PlayerState.stats.self_awareness to every node
# in the "awareness_gated" group. See ADR-011 and palette.md §3 for
# the awakening-arc spec. This is Path B from issue #12 — per-node
# gating. A post-process shader (Path A) can supersede this later
# without breaking the API if gated nodes route through apply_awareness.

const GROUP := "awareness_gated"

signal level_changed(level: int)

# Autoload-to-autoload references through the bare identifier fail to
# parse in some load orderings. Going through /root is robust and
# doesn't depend on parser symbol-table state.
@onready var _player_state: Node = get_node("/root/PlayerState")


func _ready() -> void:
	_player_state.stats_changed.connect(_on_stats_changed)
	# Broadcast once at startup so late-joining gated nodes get the
	# current value on their first _ready.
	call_deferred("_broadcast", current_level())


func current_level() -> int:
	return _player_state.stats.self_awareness


# Debug input — [ decreases, ] increases self_awareness by 25.
# D fires a multi-stat drift packet to visually verify PlayerState.apply_drift.
# Remove once a real character-creation / cheat UI exists.
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_BRACKETRIGHT:
		_player_state.stats.adjust_stat("self_awareness", 25)
	elif key_event.keycode == KEY_BRACKETLEFT:
		_player_state.stats.adjust_stat("self_awareness", -25)
	elif key_event.keycode == KEY_D:
		_player_state.apply_drift(
			{
				"authenticity": 5,
				"social_capital": -3,
				"self_awareness": 2,
			},
			"debug drift test",
		)


func _on_stats_changed(stat_name: String, new_value: int) -> void:
	if stat_name != "self_awareness":
		return
	_broadcast(new_value)


func _broadcast(level: int) -> void:
	level_changed.emit(level)
	for node in get_tree().get_nodes_in_group(GROUP):
		if node.has_method("apply_awareness"):
			node.apply_awareness(level)
