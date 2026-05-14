extends CardEffect
class_name MoveEffect


var move_distance: int
var moved_pawn: Pawn
var target_slot: CardSlot
var keep_lane: bool


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	move_distance = args.get("move_distance", 1)
	keep_lane = args.get("keep_lane", false)
	mini_icon_path = "res://assets/ui/icons/boots.png"


func _play(payload: Dictionary = {}) -> void:
	moved_pawn = null
	target_slot = null
	_resolve_moved_pawn_spec(payload)
	if moved_pawn == null or not is_instance_valid(moved_pawn):
		return
		
	var input_state := _resolve_target_slot_spec(payload, true)
		
	if input_state != null:
		InputManager.push_input_state(input_state)
	else:
		_execute_played(payload)


func _execute(payload: Dictionary = {}) -> void:
	if moved_pawn == null:
		_resolve_moved_pawn_spec(payload)
	if moved_pawn == null or not is_instance_valid(moved_pawn):
		return
		
	if target_slot == null:
		_resolve_target_slot_spec(payload, false)
	if target_slot == null or not is_instance_valid(target_slot):
		return
		
	var from_slot := moved_pawn.slot
	if from_slot == null or not is_instance_valid(from_slot):
		return
		
	from_slot.move_pawn_to_slot(target_slot)
	moved_pawn = null
	target_slot = null
		
		
func _on_pick_slot(slot, input_state: ConfirmableInputState, _payload: Dictionary):
	target_slot = slot
	input_state.check("target_slot")


func _resolve_moved_pawn_spec(payload: Dictionary) -> void:
	var moved_pawn_spec := target_specs_by_key.get("moved_pawn", null) as CardEffectTargetSpec
	if moved_pawn_spec == null:
		push_warning("MoveEffect: missing target spec for moved_pawn")
		return
	if moved_pawn_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.SELF:
		moved_pawn = card_logic.owner_node as Pawn
	elif moved_pawn_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE:
		moved_pawn = moved_pawn_spec.target_selector.call(self, payload)
	else:
		push_warning("MoveEffect: unsupported targeting mode for moved_pawn: ", moved_pawn_spec.targeting_mode)
		return


func _resolve_target_slot_spec(payload: Dictionary, can_pick: bool) -> ConfirmableInputState:
	var target_slot_spec := target_specs_by_key.get("target_slot", null) as CardEffectTargetSpec
	if target_slot_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE or target_slot_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE_AND_PICK:
		target_slot = target_slot_spec.target_selector.call(self, payload)
	
	if (target_slot_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.PICK or target_slot_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE_AND_PICK) and can_pick:
		var from_slot := moved_pawn.slot
		if from_slot == null or not is_instance_valid(from_slot):
			return null
		var slots := _get_slots_within_distance(from_slot, move_distance)
		var input_state := _create_select_input_state(payload, MultiLatch.new(["target_slot"]))
		_add_select_targets_input_state(slots, _on_pick_slot, payload)
		return input_state
	
	return null


func _get_slots_within_distance(from_slot: CardSlot, max_distance: int) -> Array[CardSlot]:
	var result: Array[CardSlot] = []
	if from_slot == null:
		return result

	var field := GameManager.board.field as Field
	if field == null:
		return result

	var from_room := from_slot.lane.room
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
			for lane in target_room.lanes.values():
				if keep_lane and lane.side != from_slot.lane.side:
					continue
				for slot in lane.card_slots:
					if slot.pawn == null:
						result.append(slot)
	return result


func _on_exit_input_state():
	super._on_exit_input_state()
	moved_pawn = null
	target_slot = null