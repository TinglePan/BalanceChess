extends CardLogic
class_name DefectLogic


func _init() -> void:
	var move_effect := GenericActionPhaseMoveEffect.new()
	effects_by_trigger_type[CardEffect.TriggerType.PLAY_ACTION_PHASE].append(move_effect)
	move_effect.bind_logic(self)
