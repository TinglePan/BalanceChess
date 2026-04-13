extends Node2D
class_name CardSlot

const COLLISION_MASK := 1 << 1
const Z_INDEX := 0
const ANIMATION_DURATION := 0.2


var pawn_scene := preload("res://scenes/Pawn.tscn") as PackedScene

var pawn: Pawn


func drop(card: Card, animation_duration: float = ANIMATION_DURATION) -> void:
	add_pawn(card.data)
#	card.animate_move(drop_position, animation_duration)
	card.queue_free()
	
	
func add_pawn(data: CardData) -> void:
	if pawn:
		push_error("CardSlot already has a pawn: ", pawn.card_data.name)
		return
	var new_pawn := pawn_scene.instantiate() as Pawn
	add_child(new_pawn)
	new_pawn.global_position = $DropAnchor.global_position
	pawn = new_pawn
	pawn.load_card_data(data)
	
	
func send_pawn_to_deck(deck: Deck, index: int = 0, animation_duration: float = ANIMATION_DURATION) -> void:
	if not pawn:
		push_error("CardSlot has no pawn to send to deck")
		return
	pawn.send_to_deck(deck, index, animation_duration)
	pawn = null