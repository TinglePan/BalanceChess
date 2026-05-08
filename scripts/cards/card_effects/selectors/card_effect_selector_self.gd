extends CardEffectSelector
class_name CardEffectSelectorSelf


func _select_targets() -> Array:
	var target := card_effect.card_logic.owner_node as Pawn
	if target == null or not is_instance_valid(target):
		return []
	return [target]
	
	