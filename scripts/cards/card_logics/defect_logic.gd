extends CardLogic
class_name DefectLogic


func _init() -> void:
	var move_effect := GenericMoveEffect.new(self, {
		"cost": 1,
		"repeatable": false,
		"move_distance": 1,
		"keep_lane": true,
	})
	effects_by_trigger_type[CardEffect.TriggerType.PLAY_ACTION_PHASE].append(move_effect)