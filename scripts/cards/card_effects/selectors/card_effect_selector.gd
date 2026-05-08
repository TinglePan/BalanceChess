extends RefCounted
class_name CardEffectSelector


var card_effect: CardEffect


func _init(_card_effect: CardEffect):
	card_effect = _card_effect
	
	
func select_targets(_context: Dictionary) -> Array:
	return []
	
	
func _add_context(context: Dictionary) -> Dictionary:
	context["card_effect"] = card_effect
	context["card_logic"] = card_effect.card_logic
	if card_effect.card_logic.owner_node is Pawn:
		var pawn := card_effect.card_logic.owner_node as Pawn
		context["pawn"] = pawn
		context["slot"] = pawn.slot
		context["lane"] = pawn.slot.lane
		context["room"] = pawn.slot.lane.room
	elif card_effect.card_logic.owner_node is Card:
		var card := card_effect.card_logic.owner_node as Card
		context["card"] = card
	return context