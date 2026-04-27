extends RefCounted
class_name CardLogic



var owner_node: Node = null
var effects_by_trigger_type: Dictionary = {
	CardEffect.TriggerType.PLAY_ACTION_PHASE: [],
	CardEffect.TriggerType.TRIGGER_TURN_END: [],
	CardEffect.TriggerType.TRIGGER_ENTER_FIELD: [],
	CardEffect.TriggerType.TRIGGER_LEAVE_FIELD: [],
	CardEffect.TriggerType.TRIGGER_MOVE_IN_FIELD: [],
}


func set_owner(node: Node) -> void:
	owner_node = node
	for trigger in effects_by_trigger_type.keys():
		for effect in effects_by_trigger_type[trigger]:
			if effect is CardEffect:
				effect.bind_logic(self)


func register_effect(trigger: CardEffect.TriggerType, effect: CardEffect) -> void:
	if effect == null:
		return
	if not effects_by_trigger_type.has(trigger):
		effects_by_trigger_type[trigger] = []
	var effects := effects_by_trigger_type[trigger] as Array
	effects.append(effect)
	effect.bind_logic(self)


func get_effects_for_trigger(trigger: CardEffect.TriggerType) -> Array:
	if not effects_by_trigger_type.has(trigger):
		return []
	return effects_by_trigger_type[trigger] as Array


func trigger_effect(trigger: CardEffect.TriggerType, payload: Dictionary = {}) -> void:
	if not effects_by_trigger_type.has(trigger):
		return
	for effect in effects_by_trigger_type[trigger]:
		if effect is CardEffect:
			effect.apply(payload)


func on_enter_field(payload: Dictionary) -> void:
	trigger_effect(CardEffect.TriggerType.TRIGGER_ENTER_FIELD, payload)


func on_leave_field(payload: Dictionary) -> void:
	trigger_effect(CardEffect.TriggerType.TRIGGER_LEAVE_FIELD, payload)


func on_move_in_field(payload: Dictionary) -> void:
	trigger_effect(CardEffect.TriggerType.TRIGGER_MOVE_IN_FIELD, payload)
