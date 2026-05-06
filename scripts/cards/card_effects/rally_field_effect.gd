extends CardEffect
class_name RallyFieldEffect


var select_targets: Callable
var pick_slots: Callable


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	select_targets = args.get("select_targets", Callable())
	pick_slots = args.get("pick_slots", Callable())


func _execute(_payload: Dictionary = {}) -> void:
	if not select_targets.is_valid():
		push_warning("RallyFieldEffect: select_targets callable is not valid")
		return
	if not pick_slots.is_valid():
		push_warning("RallyFieldEffect: pick_slots callable is not valid")
		return

	var selected_pawns_value = select_targets.call(self)
	if not (selected_pawns_value is Array):
		push_warning("RallyFieldEffect: select_targets must return an Array of pawns")
		return

	var selected_pawns: Array = selected_pawns_value
	if selected_pawns.is_empty():
		return

	var picked_slots_value = pick_slots.call(self, selected_pawns)
	if not (picked_slots_value is Array):
		push_warning("RallyFieldEffect: pick_slots must return an Array of slots")
		return

	var picked_slots: Array = picked_slots_value
	var pair_count := mini(selected_pawns.size(), picked_slots.size())
	if pair_count == 0:
		return
	if selected_pawns.size() != picked_slots.size():
		push_warning("RallyFieldEffect: selected pawn count and picked slot count differ; using the shortest count")

	for i in range(pair_count):
		var pawn := selected_pawns[i] as Pawn
		if pawn == null or not is_instance_valid(pawn):
			push_warning("RallyFieldEffect: selected pawn at position %d is not valid" % i)
			continue

		var from_slot := pawn.slot
		if from_slot == null or not is_instance_valid(from_slot):
			push_warning("RallyFieldEffect: selected pawn at position %d has no valid source slot" % i)
			continue
		if from_slot.pawn != pawn:
			push_warning("RallyFieldEffect: selected pawn at position %d is not currently in its recorded source slot" % i)
			continue

		var target_slot := picked_slots[i] as CardSlot
		if target_slot == null or not is_instance_valid(target_slot):
			push_warning("RallyFieldEffect: picked slot at position %d is not valid" % i)
			continue
		if target_slot == from_slot:
			continue

		var moved := from_slot.move_pawn_to_slot(target_slot)
		if moved:
			pawn.slot = target_slot
