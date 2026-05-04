extends RefCounted
class_name CardEffect


enum TriggerType {
	PLAY_ACTION_PHASE,
	TRIGGER_TURN_END,
	TRIGGER_ENTER_FIELD,
	TRIGGER_LEAVE_FIELD,
	TRIGGER_MOVE_IN_FIELD
}


var trigger_type: TriggerType


# Action phase effects related properties
var cost := 1
var repeatable := false
var mini_icon_path: String


var card_logic = null


func _init(logic: CardLogic, _args: Dictionary) -> void:
	card_logic = logic
	trigger_type = _args.get("trigger_type", TriggerType.PLAY_ACTION_PHASE)
	cost = _args.get("cost", 1)
	repeatable = _args.get("repeatable", false)
	mini_icon_path = _args.get("mini_icon_path", "")


func apply(payload: Dictionary = {}):
	if trigger_type == TriggerType.PLAY_ACTION_PHASE:
		_play(payload)
	else:
		_execute(payload)
	
	
func _play(_payload: Dictionary = {}) -> void:
	pass
	
	
func _execute(_payload: Dictionary = {}) -> void:
	pass


