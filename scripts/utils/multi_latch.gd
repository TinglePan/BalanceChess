extends RefCounted
class_name MultiLatch

signal all_checked

var _state: Dictionary = {}      # key -> bool
var _checked_count := 0


func _init(checks: Array[String]) -> void:
	_state.clear()
	_checked_count = 0
	for c in checks:
		_state[c] = false
		

func add_check(key: String) -> void:
	if _state.has(key):
		push_warning("Duplicate latch key: %s" % key)
		return
	_state[key] = false
	
	
func has_check(key: String) -> bool:
	return _state.has(key)


func check(key: String) -> void:
	if not _state.has(key):
		return
	if _state[key]:
		return # already triggered, ignore duplicates

	_state[key] = true
	_checked_count += 1

	if _checked_count == _state.size():
		all_checked.emit()