extends CardBuff
class_name CardBuffRankMod


enum MOD_TYPE {
	SET,
	ADD,
	MULTIPLY
}


var mod_type: MOD_TYPE
var mod_value



func _init(_source, _duration_type: DURATION_TYPE, _mod_type: MOD_TYPE, _mod_value) -> void:
	super._init(_source, _duration_type)
	mod_type = _mod_type
	mod_value = _mod_value
	

	