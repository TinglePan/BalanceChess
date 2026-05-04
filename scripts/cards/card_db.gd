extends RefCounted
class_name CardDb


enum CardId {
	DEFECT,
	MOB_SLIME,
	GOLD_NUGGET,
}

const LOGIC_SCRIPT_BY_CARD := {
	CardId.DEFECT: preload("res://scripts/cards/card_logics/defect_logic.gd"),
	CardId.MOB_SLIME: preload("res://scripts/cards/card_logics/mob_slime_logic.gd"),
	CardId.GOLD_NUGGET: preload("res://scripts/cards/card_logics/gold_nugget_logic.gd"),
}


static var MONSTER_CARDS := {
	CardId.DEFECT: CardData.new(CardId.DEFECT, "defect", CardData.CardType.MONSTER, "res://assets/sprites/defect.png", "Defect robot", 1),
	CardId.MOB_SLIME: CardData.new(CardId.MOB_SLIME, "mob_slime", CardData.CardType.MONSTER, "res://assets/sprites/mob_slime.png", "Mob slime", 1),
}

static var ITEM_CARDS := {
	CardId.GOLD_NUGGET: CardData.new(CardId.GOLD_NUGGET, "gold_nugget", CardData.CardType.ITEM, "res://assets/sprites/gold_nugget.png", "Gold nugget."),
}


static func create_card_logic(card_data: CardData, owner: Node) -> CardLogic:
	if card_data == null:
		return null
	var logic_script: GDScript = LOGIC_SCRIPT_BY_CARD.get(card_data.id)
	if logic_script == null:
		return null
	return logic_script.new(card_data, owner) as CardLogic
