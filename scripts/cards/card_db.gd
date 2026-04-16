extends RefCounted
class_name CardDb



static var MONSTER_CARDS := {
	"defect": CardData.new("defect", CardData.CardType.MONSTER, "res://assets/sprites/defect.png", "Defect robot", 1),
	"mob_slime": CardData.new("mob_slime", CardData.CardType.MONSTER, "res://assets/sprites/mob_slime.png", "Mob slime", 1),
}

static var ITEM_CARDS := {
	"gold_nugget": CardData.new("gold_nugget", CardData.CardType.ITEM, "res://assets/sprites/gold_nugget.png", "Gold nugget."),
}