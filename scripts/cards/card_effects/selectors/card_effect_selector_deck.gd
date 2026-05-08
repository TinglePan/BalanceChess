extends CardEffectSelector
class_name CardEffectSelectorDeck


var target_deck: Deck
var filter: Callable


func _init(_card_effect: CardEffect, _target_deck: Deck, _filter: Callable) -> void:
	super._init(_card_effect)
	target_deck = _target_deck
	filter = _filter
	

func select_targets(_context: Dictionary) -> Array:
	_context = _add_context(_context)
	var indexes := []
	for i in range(target_deck.card_data_list.size()):
		var card_data := target_deck.card_data_list[i] as CardData
		if filter.call(_context, card_data):
			indexes.append(i)
	return indexes
