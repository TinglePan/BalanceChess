extends CardEffectSelector
class_name CardEffectSelectorField


var slot_filter: Callable
var pawn_filter: Callable


func _init(_card_effect: CardEffect, _slot_filter: Callable, _pawn_filter: Callable) -> void:
	super._init(_card_effect)
	slot_filter = _slot_filter
	pawn_filter = _pawn_filter


func select_targets(_context: Dictionary) -> Array:
	_context = _add_context(_context)
	var selected_slots = slot_filter.call(_context) if slot_filter != null and slot_filter.is_valid() else []
	var selected_pawns := []
	for slot in selected_slots:
		if slot != null and is_instance_valid(slot):
			if slot.pawn != null and is_instance_valid(slot.pawn):
				if pawn_filter != null and pawn_filter.is_valid() and pawn_filter.call(_context, slot, slot.pawn):
					selected_pawns.append(slot.pawn)
	return selected_pawns

