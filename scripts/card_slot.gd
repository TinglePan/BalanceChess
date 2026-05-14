extends Node2D
class_name CardSlot

const COLLISION_MASK := 1 << 1
const Z_INDEX := 0
const ANIMATION_DURATION := 0.2


var pawn_scene := preload("res://scenes/Pawn.tscn") as PackedScene

var lane: Lane
var area: Area2D
var pawn: Pawn


func _ready() -> void:
	lane = get_parent() as Lane
	area = $Area2D as Area2D
	
	
func is_empty() -> bool:
	return pawn == null
	
	
func drop_position() -> Vector2:
	return $DropAnchor.global_position
	

func drop(card: Card, _animation_duration: float = ANIMATION_DURATION) -> void:
	add_pawn(card.logic.data, null)
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
	var logic := CardDb.create_card_logic(data, pawn)
	pawn.load(logic)
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
	pawn.global_position = target_slot.drop_position()
	target_slot.pawn = pawn
	BoardEvents.publish(BoardEvents.CARD_MOVED_BETWEEN_SLOTS, {
		"from_slot": self,
		"to_slot": target_slot,
		"from_pawn": pawn,
	})
	pawn.slot = target_slot
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


func coordinates() -> Array:
	return [lane.room.coordinates(), lane.side, lane.slot_index(self)]