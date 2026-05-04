extends Node2D
class_name Room


var lanes: Dictionary[Lane.LaneSide, Lane]
var area: Area2D


func _ready() -> void:
	lanes = {
		$PlayerLane.side: $PlayerLane as Lane,
		$EnemyLane.side: $EnemyLane as Lane
	}
	
	area = $Area2D as Area2D
	set_engaging_index(0)


func player_lane() -> Lane:
	return lanes[Lane.LaneSide.PLAYER]
	
	
func enemy_lane() -> Lane:
	return lanes[Lane.LaneSide.ENEMY]


# Get room size from child node Area2D
func get_size() -> Vector2:
	var collision_shape := area.get_node("CollisionShape2D") as CollisionShape2D
	var rect_shape := collision_shape.shape as RectangleShape2D
	var scaled_size := rect_shape.size * collision_shape.global_scale.abs() as Vector2
	return scaled_size


func set_engaging_index(index: int):
	if index > 0:
		$Label.text = str(index)
	else:
		$Label.text = ""


func resolve_battle():
	var pl := player_lane()
	var el := enemy_lane()
	var player_total_rank := pl.get_total_rank() as int
	var enemy_total_rank := el.get_total_rank() as int
	
	if player_total_rank > enemy_total_rank:
		pl.send_all_pawns_to_deck(GameManager.board.discard_pile)
		el.send_all_pawns_to_deck(GameManager.board.graveyard)
		print("Player wins the battle in ", GameManager.board.field.room_index(self))
	elif player_total_rank < enemy_total_rank:
		pl.send_all_pawns_to_deck(GameManager.board.graveyard)
		el.send_all_pawns_to_deck(GameManager.board.discard_pile)
		print("Enemy wins the battle in ", GameManager.board.field.room_index(self))
	else:
		pl.send_all_pawns_to_deck(GameManager.board.graveyard)
		el.send_all_pawns_to_deck(GameManager.board.graveyard)
		print("The battle is a draw in ", GameManager.board.field.room_index(self))


func coordinates() -> Vector2i:
	var field := GameManager.board.field as Field
	return field.room_index(self)