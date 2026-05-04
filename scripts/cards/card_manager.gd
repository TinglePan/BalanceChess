extends Node2D
class_name CardManager


var screen_size: Vector2
var card_dragging: Card
var card_hovering: Card
var pawn_focusing: Pawn


@export var card_scene := preload("res://scenes/card.tscn")
@export var card_slot_scene := preload("res://scenes/card_slot.tscn")


var hand_card_size: Vector2


func _ready() -> void:
	screen_size = get_viewport().size
	
	
func _enter_tree() -> void:
	call_deferred("register_card_drag_input_handler") # Defer to ensure Board is ready to receive input state registration
	

func _process(_delta: float) -> void:
	if card_dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		card_dragging.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))
		
		
func _exit_tree() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.deregister_fallback_mouse_button_event_handler(Card.DRAG_BUTTON, _on_drag_button_event)
	

func create_card_at(card_data: CardData, pos: Vector2) -> Card:
	var card := card_scene.instantiate() as Card
	card.mouse_entered.connect(hover_over.bind(card))
	card.mouse_exited.connect(hover_off.bind(card))
	card.drag_started.connect(start_drag.bind(card))
	var card_logic := CardDb.create_card_logic(card_data, card)
	card.load(card_logic)
	card.global_position = pos
	add_child(card)
	return card
	
	
func raycast4card_at_mouse(canvas_instance_id: int = 0) -> Card:
	var mouse_pos := get_viewport().get_mouse_position()
	var collider := InputManager.raycast_topmost(mouse_pos, [canvas_instance_id], InputManager.DEFAULT_COLLISION_LAYER)
	var card := collider.get_parent() as Card if collider else null
	return card
	
	
func hover_over(card: Card):
	if not card_dragging:
		var topmost_card := raycast4card_at_mouse(InputManager.ui_canvas_instance_id)
		if topmost_card == card:
			if card_hovering and card_hovering != card:
				card_hovering.toggle_highlight(false)
			card.toggle_highlight(true)
			card_hovering = card
			
			
func hover_off(card: Card):
	if not card_dragging:
		if card == card_hovering:
			card.toggle_highlight(false)
		var topmost_card := raycast4card_at_mouse(InputManager.ui_canvas_instance_id)
		if topmost_card and topmost_card != card_hovering:
			hover_over(topmost_card)
	
	
func start_drag(card: Card):
	card_dragging = card
	card.on_start_drag()


func stop_drag():
	if card_dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		var collider := InputManager.raycast_topmost(mouse_pos, [0], InputManager.DEFAULT_COLLISION_LAYER)
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
		
		
func focus_pawn(pawn: Pawn):
	if pawn_focusing and pawn_focusing != pawn:
		pawn_focusing.on_unfocused()
	pawn.on_focused()
	pawn_focusing = pawn


func _on_drag_button_event(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	if not event.pressed:
		if card_dragging:
			stop_drag()
			return true
	return false
	

func register_card_drag_input_handler():
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.register_fallback_mouse_button_event_handler(Card.DRAG_BUTTON, _on_drag_button_event)
