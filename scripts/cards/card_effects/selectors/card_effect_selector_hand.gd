extends CardEffectSelector
class_name CardEffectSelectorHand


var filter: Callable


func _init(_card_effect: CardEffect, _filter: Callable) -> void:
	super._init(_card_effect)
	filter = _filter


func _select_targets(_context: Dictionary) -> Array:
	_context = _add_context(_context)
	var hand := GameManager.board.player_hand
	var target_cards := []
	for card in hand.cards:
		if filter.call(_context, card):
			target_cards.append(card)
	return target_cards