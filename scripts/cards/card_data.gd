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


var id: CardDb.CardId
var name: String
var type: CardType
var sprite_path: String
var description: String

# Rank for Monster, Trap, Spell cards.
var original_rank: int


# Dynamic properties
var rank_mods: Array[Callable]


func _init(_id: CardDb.CardId, _name: String, _type: CardType, _sprite_path: String, _description: String, _rank: int = 0):
	id = _id
	name = _name
	type = _type
	description = _description
	sprite_path = _sprite_path
	original_rank = _rank
	
	rank_mods = []
	

func rank() -> int:
	var modified_rank := original_rank
	for mod in rank_mods:
		modified_rank += mod.call()
	return max(modified_rank, 0)
