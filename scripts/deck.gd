extends Node2D
class_name Deck


const ANIMATION_DURATION := 0.2
const DEAL_CARD_BUTTON := MOUSE_BUTTON_LEFT

var card_data_list := []


func _ready() -> void:
	GameManager.deck_ref = self
	InputManager.register_mouse_button_event_handler(DEAL_CARD_BUTTON, $Area2D, _on_deal_card_button_event)
	
	
func _exit_tree() -> void:
	if GameManager.deck_ref == self:
		GameManager.deck_ref = null
		InputManager.deregister_mouse_button_event_handler(DEAL_CARD_BUTTON, $Area2D, _on_deal_card_button_event)


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
	
	
func _on_deal_card_button_event(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	if event.is_pressed() and card_data_list.size() > 0:
		deal_card(GameManager.player_hand_ref)
		return true
	return false