extends RefCounted
class_name CardEffect


enum TriggerType {
	PLAY_ACTION_PHASE,
	TRIGGER_TURN_END,
	PLAY_THEN_TRIGGER_TURN_END,
	TRIGGER_ENTER_FIELD,
	TRIGGER_LEAVE_FIELD,
	TRIGGER_MOVE_IN_FIELD
}


var trigger_type: TriggerType
var target_specs_by_key: Dictionary


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
	var target_specs := _args.get("target_specs", []) as Array
	target_specs_by_key = {}
	for target_spec in target_specs:
		var key := target_spec.key as String
		if key == "":
			push_warning("CardEffect: target_spec with empty key will be ignored")
			continue
		target_specs_by_key[key] = target_spec


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
	
	
func _create_select_input_state(payload, confirm_checks: MultiLatch = null) -> InputState:
	var input_state := ConfirmableInputState.new(
		InputState.InputStateType.BOARD_PICK_SLOTS_PAWNS,
		{
			"confirm_checks": confirm_checks,
			"on_enter_callback": _on_enter_input_state,
			"on_exit_callback": _on_exit_input_state,
			"on_confirm_callback": _gen_on_confirm_input_state_handler(payload),
		}
	)
	input_state.register_fallback_mouse_button_event_handler(
		MOUSE_BUTTON_RIGHT,
		func(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
			if not event.is_pressed():
				return false
			InputManager.exit_input_state(input_state)
			return true
	)
	return input_state


func _add_select_targets_input_state(targets: Array, select_callback: Callable, payload: Dictionary, input_state: InputState = null) -> InputState:
	for target in targets:
		input_state.register_mouse_button_event_handler(
			MOUSE_BUTTON_LEFT,
			target.area,
			func(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
				if not event.is_pressed():
					return false
				select_callback.call(target, input_state, payload)
				return true
		)
	return input_state
	
	
func _on_enter_input_state():
	pass


func _on_exit_input_state():
	# Close the interaction menu when entering move selection mode.
	var pawn := card_logic.owner_node as Pawn
	if pawn != null and is_instance_valid(pawn) and pawn.interaction_menu != null:
		pawn.interaction_menu.close()
		
		
func _gen_on_confirm_input_state_handler(payload) -> Callable:
	return func() -> void:
		if trigger_type == TriggerType.PLAY_ACTION_PHASE:
			_execute_played(payload)

