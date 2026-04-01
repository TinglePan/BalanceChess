extends Node2D
class_name Deck


const ANIMATION_DURATION := 0.2

var card_data_list := []


func _ready() -> void:
	GameManager.deck_ref = self
	
	
func _exit_tree() -> void:
	if GameManager.deck_ref == self:
		GameManager.deck_ref = null


func add_card_data(card_data: CardData):
	card_data_list.append(card_data)
	update_count_label()


func deal_card(target: Node2D, index: int = 0) -> void:
	if index < 0 or index >= card_data_list.size():
		push_error("Invalid card index: ", index)
		return
	if card_data_list.size() == 0:
		print("No cards left in deck")
		return
	var card_data = card_data_list.pop_at(index)
	if target is PlayerHand:
		var card = GameManager.card_manager.create_card_at(card_data, global_position)
		target.add_card(card, ANIMATION_DURATION)
	elif target is CardSlot:
		var card = GameManager.card_manager.create_card_at(card_data, global_position)
		target.drop(card, ANIMATION_DURATION)
	update_count_label()


func update_count_label():
	$Label.text = str(card_data_list.size())