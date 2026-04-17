extends Node

# Global player-state singleton. Registered as autoload "PlayerState" in
# project.godot. Owns the runtime YouthUnitStats instance duplicated
# from the template .tres so gameplay mutations don't corrupt the asset.

const DEFAULT_STATS_PATH := "res://resources/youth_unit_stats.tres"

signal stats_changed(stat_name: String, new_value: int)

var stats: YouthUnitStats


func _ready() -> void:
	var template := load(DEFAULT_STATS_PATH) as YouthUnitStats
	if template == null:
		push_error("PlayerState: could not load %s" % DEFAULT_STATS_PATH)
		stats = YouthUnitStats.new()
	else:
		stats = template.duplicate() as YouthUnitStats
	stats.stat_changed.connect(_on_stats_changed)


# Reset the runtime stats back to the template .tres values.
# Intended for character-creation re-rolls and debug resets.
func reset_to_template() -> void:
	var template := load(DEFAULT_STATS_PATH) as YouthUnitStats
	if template == null:
		return
	if stats and stats.stat_changed.is_connected(_on_stats_changed):
		stats.stat_changed.disconnect(_on_stats_changed)
	stats = template.duplicate() as YouthUnitStats
	stats.stat_changed.connect(_on_stats_changed)
	# Emit once per stat so listeners re-read the full snapshot.
	for stat_name in YouthUnitStats.STAT_NAMES:
		stats_changed.emit(stat_name, stats.get_stat(stat_name))


func _on_stats_changed(stat_name: String, new_value: int) -> void:
	stats_changed.emit(stat_name, new_value)
