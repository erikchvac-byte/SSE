class_name YouthUnitStats
extends Resource

# The six 0-100 stats per GDD §5.2. Mutations should go through
# set_stat() or adjust_stat() so the `stat_changed` signal fires
# and clamping is enforced. Direct @export assignment works but is
# unobservable.

# Named stat_changed (not just `changed`) because Resource already
# exposes a built-in `changed` signal that fires on any property
# mutation; we need a distinct signal that carries the stat name.
signal stat_changed(stat_name: String, new_value: int)

const STAT_NAMES: Array[String] = [
	"authenticity",
	"alienation",
	"social_capital",
	"scrip",
	"independence",
	"self_awareness",
]

# "Fully normalized" defaults per GDD §1 / §6: neutral on most axes,
# self_awareness at 0 so the compound feels normal at game start.
# Character creation (§5.3) will override before gameplay begins.
@export var authenticity: int = 50
@export var alienation: int = 50
@export var social_capital: int = 50
@export var scrip: int = 50
@export var independence: int = 50
@export var self_awareness: int = 0


func get_stat(stat_name: String) -> int:
	if not stat_name in STAT_NAMES:
		push_error("YouthUnitStats.get_stat: unknown stat '%s'" % stat_name)
		return 0
	return get(stat_name)


func set_stat(stat_name: String, value: int) -> void:
	if not stat_name in STAT_NAMES:
		push_error("YouthUnitStats.set_stat: unknown stat '%s'" % stat_name)
		return
	var clamped := clampi(value, 0, 100)
	if get(stat_name) == clamped:
		return
	set(stat_name, clamped)
	stat_changed.emit(stat_name, clamped)


func adjust_stat(stat_name: String, delta: int) -> void:
	set_stat(stat_name, get_stat(stat_name) + delta)


func snapshot() -> Dictionary:
	var result: Dictionary = {}
	for n in STAT_NAMES:
		result[n] = get(n)
	return result
