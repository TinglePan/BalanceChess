extends RefCounted
class_name CardData


enum CardType {
	MONSTER,
	TRAP,
	ITEM,
	EVENT,
	TERRITORY,
	PASSIVE,
	SKILL,
	SPELL
}

const CARD_TYPES_WITH_RANK := [
	CardType.MONSTER,
	CardType.TRAP,
	CardType.SPELL
]


var name: String
var type: CardType
var sprite_path: String
var description: String

# Rank for Monster, Trap, Spell cards.
var rank: int


func _init(_name: String, _type: CardType, _sprite_path: String, _description: String, _rank: int = 0):
	name = _name
	type = _type
	description = _description
	sprite_path = _sprite_path
	rank = _rank