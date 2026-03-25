extends RefCounted
class_name CardData


var name: String
var rank: int
var sprite_path: String


func _init(_name: String, _rank: int, _sprite_path: String):
	name = _name
	rank = _rank
	sprite_path = _sprite_path