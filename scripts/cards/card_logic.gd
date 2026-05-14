extends RefCounted
class_name CardLogic


var owner_node: Node = null

var data: CardData
var effects_by_trigger_type: Dictionary = {
	CardEffect.TriggerType.PLAY_ACTION_PHASE: [],
	CardEffect.TriggerType.TRIGGER_TURN_END: [],
	CardEffect.TriggerType.TRIGGER_ENTER_FIELD: [],
	CardEffect.TriggerType.TRIGGER_LEAVE_FIELD: [],
	CardEffect.TriggerType.TRIGGER_MOVE_IN_FIELD: [],
}
var buffs: Dictionary = {}


func _init(_data: CardData, _owner: Node) -> void:
	data = _data
	owner_node = _owner
	

func set_owner(node: Node) -> void:
	owner_node = node


func register_effect(effect: CardEffect) -> void:
	if effect == null:
		return
	var trigger := effect.trigger_type
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


func add_buff(buff: CardBuff) -> void:
	var tid = buff.tid
	if not buffs.has(tid):
		buffs[tid] = []
	if buff.is_unique:
		for existing_buff in buffs[tid]:
			if not existing_buff.is_unique:
				push_error("Buff with tid %s is marked as unique but an existing buff is not unique." % tid)
				return
			buffs[tid].erase(existing_buff)
	for existing_buff in buffs[tid]:
		if existing_buff.source == buff.source:
			existing_buff.add_stack(buff.current_stacks)
			return
	buffs[tid].append(buff)
