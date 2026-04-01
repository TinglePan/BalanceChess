extends Node2D
class_name Lane


var card_slots: Array[CardSlot]


func get_total_rank() -> int:
	var total_rank := 0
	for slot in card_slots:
		if slot.card_in_slot != null:
			total_rank += slot.card_in_slot.data.rank
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

