extends Node2D
class_name Deck


const ANIMATION_DURATION := 0.2
const DEAL_CARD_BUTTON := MOUSE_BUTTON_LEFT

var card_data_list := []
var area: Area2D
var is_picked: bool
var pick_indicator: Sprite2D


func _ready() -> void:
	area = $Area2D as Area2D
	pick_indicator = $PickIndicator as Sprite2D
	unpick()
	update_count_label()
	
	
func _enter_tree() -> void:
	call_deferred("_register_deal_card_input_handler")
	
	
func _exit_tree() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateType.BOARD_NEUTRAL)
	input_state.deregister_mouse_button_event_handler(DEAL_CARD_BUTTON, $Area2D, _on_deal_card_button_event)


func add_card_data(card_data: CardData, index: int = 0):
	var insert_index := index
	if index < 0:
		insert_index = card_data_list.size() + index + 1
		insert_index = max(insert_index, 0)
	card_data_list.insert(insert_index, card_data)
	update_count_label()


func shuffle() -> void:
	card_data_list.shuffle()


func shuffle_to(deck: Deck) -> void:
	if deck == null:
		push_error("Target deck is null")
		return
	if deck == self:
		shuffle()
		return
	deck.card_data_list.append_array(card_data_list)
	card_data_list.clear()
	update_count_label()
	deck.shuffle()


func deal_card(target: Node2D, index: int = 0) -> void:
	if index < 0 or index >= card_data_list.size():
		push_error("Invalid card index: ", index)
		return
	if card_data_list.size() == 0:
		print("No cards left in deck")
		return
	var card_data = card_data_list.pop_at(index)
	if target is PlayerHand:
		var card = GameManager.board.card_manager.create_card_at(card_data, global_position)
		target.add_card(card, ANIMATION_DURATION)
	elif target is CardSlot:
		var card = GameManager.board.card_manager.create_card_at(card_data, global_position)
		target.drop(card, ANIMATION_DURATION)
	update_count_label()
	
	
func pick():
	is_picked = true
	pick_indicator.visible = true
	
	
func unpick():
	is_picked = false
	pick_indicator.visible = false
	

func update_count_label():
	$Label.text = str(card_data_list.size())
	
	
func _on_deal_card_button_event(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	if event.is_pressed() and card_data_list.size() > 0:
		deal_card(GameManager.board.player_hand)
		return true
	return false
	

func _register_deal_card_input_handler():
	var input_state := InputManager.get_input_state(InputState.InputStateType.BOARD_NEUTRAL)
	input_state.register_mouse_button_event_handler(DEAL_CARD_BUTTON, $Area2D, _on_deal_card_button_event)