extends Node2D
class_name CardSlot

const COLLISION_MASK := 1 << 1
const Z_INDEX := 0
const ANIMATION_DURATION := 0.2


var card_in_slot: Card = null
@onready var drop_position := $DropAnchor.global_position as Vector2


func drop(card: Card, animation_duration: float = ANIMATION_DURATION) -> void:
	card.animate_move(drop_position, animation_duration)
	card_in_slot = card
	card.current_holder = self


