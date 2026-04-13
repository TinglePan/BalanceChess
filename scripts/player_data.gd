extends RefCounted
class_name PlayerData


var life: int
var max_life: int
var sync_point: int
var max_sync_point: int
var mana: int
var max_mana: int
var base_hand_size: int


func _init(_max_life: int, _max_sync_point: int, _max_mana: int, _base_hand_size: int):
	life = _max_life
	max_life = _max_life
	sync_point = _max_sync_point
	max_sync_point = _max_sync_point
	mana = _max_mana
	max_mana = _max_mana
	base_hand_size = _base_hand_size
	

