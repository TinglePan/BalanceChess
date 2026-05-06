extends CardEffect
class_name RallyDeckEffect


var target_deck: Deck
var select_targets: Callable
var pick_slots: Callable


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	target_deck = args.get("target_deck", null) as Deck
	select_targets = args.get("select_targets", Callable())
	pick_slots = args.get("pick_slots", Callable())


func _execute(_payload: Dictionary = {}) -> void:
	if target_deck == null or not is_instance_valid(target_deck):
		push_warning("RallyDeckEffect: target_deck is not valid")
		return
	if not select_targets.is_valid():
		push_warning("RallyDeckEffect: select_targets callable is not valid")
		return
	if not pick_slots.is_valid():
		push_warning("RallyDeckEffect: pick_slots callable is not valid")
		return

	var selected_indexes_value = select_targets.call(self)
	if not (selected_indexes_value is Array):
		push_warning("RallyDeckEffect: select_targets must return an Array of deck indexes")
		return

	var selected_indexes: Array = selected_indexes_value
	if selected_indexes.is_empty():
		return

	var picked_slots_value = pick_slots.call(self, selected_indexes)
	if not (picked_slots_value is Array):
		push_warning("RallyDeckEffect: pick_slots must return an Array of slots")
		return

	var picked_slots: Array = picked_slots_value
	
	if selected_indexes.size() != picked_slots.size():
		push_warning("RallyDeckEffect: selected index count and picked slot count differ; using the shortest count")

	var pair_count := mini(selected_indexes.size(), picked_slots.size())
	if pair_count == 0:
		return

	# Keep effect order stable while compensating deck index shifts after each deal.
	for i in range(pair_count):
		var raw_index = selected_indexes[i]
		if typeof(raw_index) != TYPE_INT:
			push_warning("RallyDeckEffect: selected index at position %d is not an int" % i)
			continue

		var deck_index: int = raw_index
		if deck_index < 0 or deck_index >= target_deck.card_data_list.size():
			push_warning("RallyDeckEffect: selected index %d is out of bounds" % deck_index)
			continue

		var target_slot := picked_slots[i] as CardSlot
		if target_slot == null or not is_instance_valid(target_slot):
			push_warning("RallyDeckEffect: picked slot at position %d is not valid" % i)
			continue

		target_deck.deal_card(target_slot, deck_index)

		# The deck shrinks after pop_at; keep remaining indexes aligned to the original selection.
		for j in range(i + 1, pair_count):
			if typeof(selected_indexes[j]) == TYPE_INT and selected_indexes[j] > deck_index:
				selected_indexes[j] -= 1
