extends GenericMoveEffect
class_name CarrierMoveEffect


var carry_capacity: int
var carried_pawns: Array[Pawn]


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	carry_capacity = args.get("carry_capacity", 1)
	carried_pawns = []


func _play(payload: Dictionary = {}) -> void:
	var pawn := card_logic.owner_node as Pawn
	if pawn == null or not is_instance_valid(pawn):
		return

	var from_slot := pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return

	_input_state = InputState.new(
		InputState.InputStateId.BOARD_MOVE_PICK_SLOT_CARRIER,
		[0]
	)
	_register_input_handlers_for_candidate_slots(_input_state, pawn, from_slot, payload)
	_register_input_handlers_for_candidate_pawns(_input_state, pawn, from_slot)

	_input_state.register_fallback_mouse_button_event_handler(
		MOUSE_BUTTON_RIGHT,
		func(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
			if not event.is_pressed():
				return false
			_exit_move_pick_state()
			return true
	)

	InputManager.push_input_state(_input_state)


func _execute(payload: Dictionary = {}) -> void:
	var carrier_pawn := card_logic.owner_node as Pawn
	if carrier_pawn == null or not is_instance_valid(carrier_pawn):
		return

	var from_slot := carrier_pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return

	var target_slot := payload.get("target_slot", null) as CardSlot
	var moved := from_slot.move_pawn_to_slot(target_slot)
	if not moved:
		return

	carrier_pawn.slot = target_slot
	_move_carried_pawns(target_slot)
	_exit_move_pick_state()


func _exit_move_pick_state() -> void:
	super._exit_move_pick_state()
	carried_pawns.clear()
	
	
func _register_input_handlers_for_candidate_pawns(input_state: InputState, carrier_pawn: Pawn, from_slot: CardSlot) -> void:
	var candidates: Array[Pawn] = []
	var lane := from_slot.lane
	for slot in lane.card_slots:
		var candidate: Pawn = slot.pawn
		if candidate == null or candidate == carrier_pawn:
			continue
		candidates.append(candidate)
	for candidate_pawn in candidates:
		input_state.register_mouse_button_event_handler(
			MOUSE_BUTTON_LEFT,
			candidate_pawn.area,
			func(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
				if not event.is_pressed():
					return false
				_toggle_carried_pawn(candidate_pawn)
				return true
		)


func _toggle_carried_pawn(candidate_pawn: Pawn) -> void:
	if candidate_pawn == null or not is_instance_valid(candidate_pawn):
		return

	var existing_index := carried_pawns.find(candidate_pawn)
	if existing_index != -1:
		carried_pawns.remove_at(existing_index)
		return

	if carry_capacity <= 0 or carried_pawns.size() >= carry_capacity:
		return

	carried_pawns.append(candidate_pawn)


func _move_carried_pawns(target_slot: CardSlot) -> void:
	var lane := target_slot.lane
	var next_slot := lane.next_slot(target_slot)

	for carried_pawn in carried_pawns:
		if next_slot.is_empty():
			var from_slot := carried_pawn.slot
			if from_slot == null or not is_instance_valid(from_slot):
				continue
	
			var moved := from_slot.move_pawn_to_slot(next_slot)
			if not moved:
				continue
			carried_pawn.slot = next_slot
			next_slot = lane.next_slot(next_slot)
		else:
			break




