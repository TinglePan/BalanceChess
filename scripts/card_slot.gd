extends Node2D
class_name CardSlot

const COLLISION_MASK := 1 << 1
const Z_INDEX := 0
const ANIMATION_DURATION := 0.2


var pawn_scene := preload("res://scenes/Pawn.tscn") as PackedScene

@onready var drop_position: Vector2 = $DropAnchor.global_position
var pawn: Pawn


func _ready() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, $Area2D, _on_mouse_button_event)


func _exit_tree() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, $Area2D, _on_mouse_button_event)


func drop(card: Card, _animation_duration: float = ANIMATION_DURATION) -> void:
	add_pawn(card.data, null)
#	card.animate_move(drop_position, animation_duration)
	card.queue_free()
	
	
func add_pawn(data: CardData, from_slot: CardSlot = null) -> void:
	if pawn:
		push_error("CardSlot already has a pawn: ", pawn.card_data.name)
		return
	var new_pawn := pawn_scene.instantiate() as Pawn
	add_child(new_pawn)
	new_pawn.global_position = $DropAnchor.global_position
	pawn = new_pawn
	pawn.load_data(data)
	var logic := CardDb.create_card_logic(data)
	pawn.logic = logic
	if from_slot == null:
		BoardEvents.publish(BoardEvents.CARD_ENTERED_FIELD, {
			"pawn": pawn,
			"slot": self,
		})
	else:
		BoardEvents.publish(BoardEvents.CARD_MOVED_BETWEEN_SLOTS, {
			"pawn": pawn,
			"from_slot": from_slot,
			"to_slot": self,
		})


func move_pawn_to_slot(target_slot: CardSlot) -> bool:
	if pawn == null:
		return false
	if target_slot == null or not is_instance_valid(target_slot):
		return false
	if target_slot == self or target_slot.pawn != null:
		return false

	remove_child(pawn)
	target_slot.add_child(pawn)
	pawn.global_position = target_slot.drop_position
	target_slot.pawn = pawn
	BoardEvents.publish(BoardEvents.CARD_MOVED_BETWEEN_SLOTS, {
		"from_slot": self,
		"to_slot": target_slot,
		"from_pawn": pawn,
	})
	pawn = null
	return true
	
	
func send_pawn_to_deck(deck: Deck, index: int = 0, animation_duration: float = ANIMATION_DURATION) -> void:
	if not pawn:
		push_error("CardSlot has no pawn to send to deck")
		return
	pawn.send_to_deck(deck, index, animation_duration)
	BoardEvents.publish(BoardEvents.CARD_LEFT_FIELD, {
		"pawn": pawn,
		"slot": self,
		"deck": deck,
	})
	pawn = null


func _on_mouse_button_event(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	if not event.is_pressed():
		return false
	var board := GameManager.board
	if board.input_state == Board.InputState.PICK_SLOT:
		# TODO
		return true
	return false

