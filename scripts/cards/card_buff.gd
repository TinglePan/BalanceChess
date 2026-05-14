extends RefCounted
class_name CardBuff


enum DURATION_TYPE {
	ALWAYS,
	UNTIL_TURN_END,
	UNTIL_SOURCE_INVALID
}


var uid
var tid
var source
var duration_type: DURATION_TYPE
var is_unique: bool = false
var current_stacks: int = 1
var max_stacks: int = 1


func _init(_source, _duration_type: DURATION_TYPE, _is_unique: bool = false, _max_stacks: int = 1):
	uid = str(self.get_instance_id())
	source = _source
	duration_type = _duration_type
	is_unique = _is_unique
	max_stacks = _max_stacks
	current_stacks = 1
	

func add_stack(stacks: int = 1) -> void:
	current_stacks = min(current_stacks + stacks, max_stacks)