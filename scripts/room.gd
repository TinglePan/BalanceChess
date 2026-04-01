extends Node2D
class_name Room


var player_lane: Lane
var enemy_lane: Lane


# Get room size from child node Area2D
func get_size() -> Vector2:
	var area := $Area2D
	var collision_shape := area.get_node("CollisionShape2D") as CollisionShape2D
	var rect_shape := collision_shape.shape as RectangleShape2D
	var scaled_size := rect_shape.size * collision_shape.global_scale.abs() as Vector2
	return scaled_size


func resolve_battle():
	var player_total_rank := player_lane.get_total_rank()
	var enemy_total_rank := enemy_lane.get_total_rank()
	
	if player_total_rank > enemy_total_rank:
		print("Player wins the battle!")
	elif player_total_rank < enemy_total_rank:
		print("Enemy wins the battle!")
	else:
		print("The battle is a draw!")
