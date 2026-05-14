extends RefCounted
class_name CardEffectTargetSpec


enum TargetingType {
	DECKS,
	PAWNS,
	SLOTS
}

enum TargetingMode {
	PICK,
	SELF,
	COMPUTE,
	COMPUTE_AND_PICK,
}


var key: String
var targeting_type: TargetingType
var targeting_mode: TargetingMode

# For COMPUTE targeting modes, a callable that takes (effect: CardEffect, payload: Dictionary) and returns the computed target(s).
var target_selector: Callable

# For PICK targeting modes, a callable that takes (effect: CardEffect, payload: Dictionary) and returns an Array of candidate targets to pick from.
var candidate_selector: Callable


func _init(_key: String, _targeting_type: TargetingType, _targeting_mode: TargetingMode, _target_selector: Callable = Callable(), _candidate_selector: Callable = Callable()) -> void:
	key = _key
	targeting_type = _targeting_type
	targeting_mode = _targeting_mode
	target_selector = _target_selector
	candidate_selector = _candidate_selector

