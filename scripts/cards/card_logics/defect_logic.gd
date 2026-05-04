extends CardLogic
class_name DefectLogic


func _init() -> void:
	var move_effect := GenericActionPhaseMoveEffect.new(self, 1)
	effects_by_trigger_type[CardEffect.TriggerType.PLAY_ACTION_PHASE].append(move_effect)