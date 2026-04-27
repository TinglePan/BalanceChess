extends RefCounted
class_name CardEffect


enum TriggerType {
	PLAY_ACTION_PHASE,
	TRIGGER_TURN_END,
	TRIGGER_ENTER_FIELD,
	TRIGGER_LEAVE_FIELD,
	TRIGGER_MOVE_IN_FIELD
}


var card_logic = null


func _init(logic: CardLogic) -> void:
	card_logic = logic


func apply(_payload: Dictionary) -> void:
	pass


