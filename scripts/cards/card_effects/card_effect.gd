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
var cooldown := 0
var mini_icon_path: String


var card_logic = null


func _init(logic: CardLogic, _args: Dictionary) -> void:
	card_logic = logic
	trigger_type = _args.get("trigger_type", TriggerType.PLAY_ACTION_PHASE)
	cost = _args.get("cost", 1)
	repeatable = _args.get("repeatable", false)
	mini_icon_path = _args.get("mini_icon_path", "")


func apply(payload: Dictionary = {}) -> void:
	if trigger_type == TriggerType.PLAY_ACTION_PHASE:
		if not can_play():
			return
		_play(payload)
	else:
		_execute_triggered(payload)
		
		
func can_play() -> bool:
	return cooldown == 0 and GameManager.board.player_board_data.sp >= cost
		
		
func on_turn_end():
	if cooldown > 0:
		cooldown -= 1
	
	
func _play(payload: Dictionary = {}) -> void:
	_execute_played(payload)
	
	
func _execute_played(payload: Dictionary = {}) -> void:
	_execute(payload)
	if not repeatable:
		cooldown = 1
	GameManager.board.consume_sp(cost)
	
	
	
func _execute_triggered(payload: Dictionary = {}) -> void:
	_execute(payload)

	
func _execute(_payload: Dictionary = {}) -> void:
	pass


