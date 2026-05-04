extends RefCounted
class_name PlayerBoardData


var player_data: PlayerData

var hp: int
var sp: int
var mp: int


func _init(_player_data: PlayerData):
	player_data = _player_data
	hp = player_data.max_hp
	sp = player_data.max_sp
	mp = player_data.max_mp
	
