extends MoveEffect
class_name CarrierMoveEffect


var carry_capacity: int
var carried_pawns: Array[Pawn]


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	carry_capacity = args.get("carry_capacity", 1)
	carried_pawns = []


func _play(payload: Dictionary = {}) -> void:
	moved_pawn = null
	target_slot = null
	carried_pawns.clear()
	
	_resolve_moved_pawn_spec(payload)
		
	var input_state := _resolve_target_slot_spec(payload, true)
	
	input_state = _resolve_carried_pawns_spec(payload, true, input_state)
	
	if input_state != null:
		InputManager.push_input_state(input_state)
	else:
		_execute_played(payload)


func _execute(_payload: Dictionary = {}) -> void:
	if moved_pawn == null:
		_resolve_moved_pawn_spec(_payload)
	if moved_pawn == null or not is_instance_valid(moved_pawn):
		return
	
	var from_slot := moved_pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return

	var moved := from_slot.move_pawn_to_slot(target_slot)
	if not moved:
		return
	
	if carried_pawns.is_empty():
		_resolve_carried_pawns_spec(_payload, false, null)

	var lane := target_slot.lane
	var next_slot := lane.next_slot(target_slot)

	for carried_pawn in carried_pawns:
		if next_slot.is_empty():
			var carried_pawn_from_slot := carried_pawn.slot
			if carried_pawn_from_slot == null or not is_instance_valid(carried_pawn_from_slot):
				continue
	
			carried_pawn_from_slot.move_pawn_to_slot(next_slot)
			next_slot = lane.next_slot(next_slot)
		else:
			break
	moved_pawn = null
	target_slot = null
	carried_pawns.clear()
	
	
func _on_enter_input_state():
	super._on_enter_input_state()
	for carried_pawn in carried_pawns:
		if carried_pawn != null and is_instance_valid(carried_pawn):
			carried_pawn.pick()
	
	
func _on_exit_input_state():
	super._on_exit_input_state()
	for carried_pawn in carried_pawns:
		if carried_pawn != null and is_instance_valid(carried_pawn):
			carried_pawn.unpick()
	carried_pawns.clear()
	

func _on_pick_pawn(pawn: Pawn, _input_state: ConfirmableInputState, _payload: Dictionary) -> void:
	if pawn == null or not is_instance_valid(pawn):
		return

	var existing_index := carried_pawns.find(pawn)
	if existing_index != -1:
		pawn.unpick()
		carried_pawns.remove_at(existing_index)
		return

	if carry_capacity <= 0 or carried_pawns.size() >= carry_capacity:
		return
		
	pawn.pick()
	carried_pawns.append(pawn)
	if carried_pawns.size() >= carry_capacity:
		_input_state.check("carried_pawns")
		
		
func _resolve_carried_pawns_spec(payload: Dictionary, can_pick: bool, input_state: ConfirmableInputState) -> ConfirmableInputState:
	var carried_pawns_spec := target_specs_by_key.get("carried_pawns", null) as CardEffectTargetSpec
	if carried_pawns_spec == null:
		push_warning("MoveEffect: missing target spec for carried_pawns")
		return
	if carried_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE or carried_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE_AND_PICK:
		carried_pawns = carried_pawns_spec.target_selector.call(self, payload)
	if (carried_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.PICK or carried_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE_AND_PICK) and can_pick:
		# NOTE: if target slot is picked, the input state is supposed to be not null, and the carried_pawns check will not be added. This is intended.
		if input_state == null:
			input_state = _create_select_input_state(payload, MultiLatch.new(["carried_pawns"]))
		var candidate_pawns: Array
		if carried_pawns_spec.candidate_selector != null and carried_pawns_spec.candidate_selector.is_valid():
			var candidate_pawns_value = carried_pawns_spec.candidate_selector.call(self, payload)
			if candidate_pawns_value is Array:
				candidate_pawns = candidate_pawns_value
		else:
			candidate_pawns = _default_candidate_pawns_selector()
		input_state = _add_select_targets_input_state(candidate_pawns, _on_pick_pawn, payload, input_state)
		return input_state
	return null


func _default_candidate_pawns_selector() -> Array[Pawn]:
	var candidate_pawns := []
	var from_slot := moved_pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return candidate_pawns

	var from_lane := from_slot.lane
	for slot in from_lane.card_slots:
		if not slot.is_empty():
			var slot_pawn := slot.pawn
			if slot_pawn != null and is_instance_valid(slot_pawn) and slot_pawn != moved_pawn:
				candidate_pawns.append(slot_pawn)
	return candidate_pawns