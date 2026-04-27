extends Node2D
class_name Lane


@export var card_slots: Array[CardSlot]
@export var graveyard_deal_delay: float = 0.08


func get_total_rank() -> int:
	var total_rank := 0
	for slot in card_slots:
		if slot.pawn != null:
			total_rank += slot.pawn.card_data.rank
	return total_rank
	

# Get the neighbouring card slots of a given card slot in the lane, the card_slots array is a circular array, so the first and last slots are neighbours
func get_neighbour_slots(card_slot: CardSlot) -> Array[CardSlot]:
	var index := card_slots.find(card_slot)
	if index == -1:
		push_error("CardSlot not found in lane: ", card_slot.name)
		return []
	var left_index := (index - 1) % card_slots.size()
	var right_index := (index + 1) % card_slots.size()
	return [card_slots[left_index], card_slots[right_index]]


func first_empty_slot() -> CardSlot:
	for slot in card_slots:
		if slot.pawn == null:
			return slot
	return null
	
	
func send_all_pawns_to_deck(deck: Deck) -> void:
	var slots_to_send: Array[CardSlot] = []
	for slot in card_slots:
		if slot.pawn != null:
			slots_to_send.append(slot)

	for i in slots_to_send.size():
		slots_to_send[i].send_pawn_to_deck(deck)
		if i < slots_to_send.size() - 1 and graveyard_deal_delay > 0.0:
			await get_tree().create_timer(graveyard_deal_delay).timeout
	
	
func is_empty() -> bool:
	for slot in card_slots:
		if slot.pawn != null:
			return false
	return true
