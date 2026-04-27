extends ActionPhaseEffect
class_name GenericActionPhaseMoveEffect


var move_distance := 1
var _active_input_state: InputState = null


func _init(_card_logic: CardLogic, _move_distance: int) -> void:
	super._init(_card_logic)
	move_distance = _move_distance
	mini_icon_path = "res://assets/ui/icons/move_icon.png"


func apply(_payload: Dictionary) -> void:
	var pawn := card_logic.owner as Pawn
	if pawn == null or not is_instance_valid(pawn):
		return

	var from_slot := pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return

	# Close the interaction menu when entering move selection mode.
	if pawn.interaction_menu != null:
		pawn.interaction_menu.close()

	# Build and push a dedicated temporary input state for this move selection.
	_active_input_state = InputState.new(
		InputState.InputStateId.BOARD_MOVE_PICK_SLOT,
		[0]
	)

	# Left click on any valid target slot moves the pawn.
	for slot in _get_slots_within_distance(from_slot, move_distance):
		var area := slot.get_node_or_null("Area2D") as CollisionObject2D
		if area == null:
			continue
		_active_input_state.register_mouse_button_event_handler(
			MOUSE_BUTTON_LEFT,
			area,
			func(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
				if not event.is_pressed():
					return false
				move_to_slot(slot)
				return true
		)

	# Right click cancels and exits this input state.
	_active_input_state.register_fallback_mouse_button_event_handler(
		MOUSE_BUTTON_RIGHT,
		func(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
			if not event.is_pressed():
				return false
			_exit_move_pick_state()
			return true
	)

	InputManager.push_input_state(_active_input_state)


func move_to_slot(target_slot: CardSlot) -> bool:
	var pawn := card_logic.owner as Pawn
	if pawn == null or not is_instance_valid(pawn):
		return false

	var from_slot := pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return false

	var moved := from_slot.move_pawn_to_slot(target_slot)
	if moved:
		# Keep pawn.slot in sync with the move result.
		pawn.slot = target_slot
	_exit_move_pick_state()
	return moved


func _exit_move_pick_state() -> void:
	if _active_input_state == null:
		return

	# Pop only if this state is still current.
	if InputManager.current_input_state() == _active_input_state:
		InputManager.pop_input_state()
	_active_input_state = null


func _get_slots_within_distance(from_slot: CardSlot, max_distance: int) -> Array[CardSlot]:
	var result: Array[CardSlot] = []
	if from_slot == null:
		return result

	var field := GameManager.board.field as Field
	if field == null:
		return result

	var from_room := from_slot.get_parent() as Room
	if from_room == null:
		return result

	var from_index := field.room_index(from_room)
	if from_index.x < 0 or from_index.y < 0:
		return result

	for room in field.rooms:
		var target_room := room as Room
		if target_room == null:
			continue

		var target_index := field.room_index(target_room)
		if target_index.x < 0 or target_index.y < 0:
			continue

		var distance := absi(target_index.x - from_index.x) + absi(target_index.y - from_index.y)
		if distance <= max_distance:
			for slot in target_room.card_slots:
				var card_slot := slot as CardSlot
				if card_slot == null:
					continue
				if card_slot == from_slot:
					continue
				if card_slot.pawn != null:
					continue
				result.append(card_slot)

	return result