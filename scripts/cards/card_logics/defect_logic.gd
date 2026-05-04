extends CardLogic
class_name DefectLogic


func _init(_data: CardData, _owner: Node) -> void:
	super._init(_data, _owner)
	var move_effect := GenericMoveEffect.new(self, {
		"cost": 1,
		"repeatable": false,
		"move_distance": 1,
		"keep_lane": true,
	})
	effects_by_trigger_type[CardEffect.TriggerType.PLAY_ACTION_PHASE].append(move_effect)