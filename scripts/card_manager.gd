extends Node2D


var screen_size: Vector2
var card_dragging: Card
var card_hovering: Card


@export var card_scene := preload("res://scenes/card.tscn")
@export var card_slot_scene := preload("res://scenes/card_slot.tscn")


var hand_card_size: Vector2


func _ready() -> void:
	screen_size = get_viewport().size
	print("card manager ready")
	InputManager.mouse_left_button_pressed.connect(on_mouse_left_button_pressed)
	InputManager.mouse_left_button_released.connect(on_mouse_left_button_released)


func _process(delta: float) -> void:
	if card_dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		card_dragging.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))


func on_mouse_left_button_pressed():
	print("left button pressed")
	var mouse_pos := get_viewport().get_mouse_position()
#	var collider := InputManager.raycast(mouse_pos) as CollisionObject2D
	var collider := InputManager.raycast_with_mask(mouse_pos, Deck.COLLISION_MASK)
	if collider:
		if collider.collision_mask & Card.COLLISION_MASK:
			var card := collider.get_parent() as Card
			if card.can_drag:
				start_drag(card)
		elif collider.collision_mask & Deck.COLLISION_MASK:
			var deck := collider.get_parent() as Deck
			deck.deal_card(GameManager.player_hand_ref)
	
	
func on_mouse_left_button_released():
	if card_dragging:
		stop_drag()
	

func create_card_at(card_data: CardData, pos: Vector2) -> Card:
	var card := card_scene.instantiate() as Card
	card.load_data(card_data)
	card.global_position = pos
	add_child(card)
	return card
	
	
func raycast4card_at_mouse() -> Card:
	var mouse_pos := get_viewport().get_mouse_position()
	var collider := InputManager.raycast_with_mask(mouse_pos, Card.COLLISION_MASK)
	var card := collider.get_parent() as Card if collider else null
	return card
	
	
func hover_over(card: Card):
	if not card_dragging:
		var topmost_card := raycast4card_at_mouse()
		if topmost_card == card:
			card.toggle_highlight(true)
			card_hovering = card
			
			
func hover_off(card: Card):
	if not card_dragging:
		if card == card_hovering:
			card.toggle_highlight(false)
		var topmost_card := raycast4card_at_mouse()
		if topmost_card and topmost_card != card_hovering:
			hover_over(topmost_card)
	
	
func start_drag(card: Card):
	card_dragging = card
	card.on_start_drag()


func stop_drag():
	if card_dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		var collider := InputManager.raycast_with_mask(mouse_pos, CardSlot.COLLISION_MASK)
		var topmost_card_slot := collider.get_parent() as CardSlot if collider else null
		if topmost_card_slot:
			if card_dragging.current_holder is PlayerHand:
				card_dragging.current_holder.remove_card(card_dragging)
			topmost_card_slot.drop(card_dragging)
		else:
			card_dragging.animate_move(card_dragging.drag_start_pos) # Animate back to original position if not dropped in a slot
		if card_hovering == card_dragging:
			card_dragging.toggle_highlight(true) # Keep the card highlighted if it's still being hovered
		else:
			card_dragging.scale = Vector2(1, 1) # Reset scale
			card_dragging.z_index = Card.NORMAL_Z_INDEX
		card_dragging = null
