extends Node2D
class_name Room


signal clicked
var player_lane: Lane
var enemy_lane: Lane


func _ready() -> void:
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, $Area2D, _on_room_mouse_button_event)
	player_lane = $PlayerLane as Lane
	enemy_lane = $EnemyLane as Lane
	set_engaging_index(0)


func _exit_tree() -> void:
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, $Area2D, _on_room_mouse_button_event)


# Get room size from child node Area2D
func get_size() -> Vector2:
	var area := $Area2D
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
	var player_total_rank := player_lane.get_total_rank() as int
	var enemy_total_rank := enemy_lane.get_total_rank() as int
	
	if player_total_rank > enemy_total_rank:
		player_lane.send_all_pawns_to_deck(GameManager.board.discard_pile)
		enemy_lane.send_all_pawns_to_deck(GameManager.board.graveyard)
		print("Player wins the battle in ", GameManager.board.field.room_index(self))
	elif player_total_rank < enemy_total_rank:
		player_lane.send_all_pawns_to_deck(GameManager.board.graveyard)
		enemy_lane.send_all_pawns_to_deck(GameManager.board.discard_pile)
		print("Enemy wins the battle in ", GameManager.board.field.room_index(self))
	else:
		player_lane.send_all_pawns_to_deck(GameManager.board.discard_pile)
		enemy_lane.send_all_pawns_to_deck(GameManager.board.discard_pile)
		print("The battle is a draw in ", GameManager.board.field.room_index(self))
		

func _on_room_mouse_button_event(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	# Intentionally empty for now.
	if event.is_pressed():
		clicked.emit()
		return true
	return false
	
	
