extends Node2D
class_name DirectionPad


@onready var up_area: Area2D = $Up/Area2D
@onready var down_area: Area2D = $Down/Area2D
@onready var left_area: Area2D = $Left/Area2D
@onready var right_area: Area2D = $Right/Area2D
@onready var up_sprite: Sprite2D = $Up/Sprite2D
@onready var down_sprite: Sprite2D = $Down/Sprite2D
@onready var left_sprite: Sprite2D = $Left/Sprite2D
@onready var right_sprite: Sprite2D = $Right/Sprite2D


func _ready() -> void:
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, up_area, _on_up_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, down_area, _on_down_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, left_area, _on_left_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, right_area, _on_right_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_RIGHT, null, _on_cancel_alternate_input_event)


func _exit_tree() -> void:
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, up_area, _on_up_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, down_area, _on_down_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, left_area, _on_left_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, right_area, _on_right_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_RIGHT, null, _on_cancel_alternate_input_event)


func _on_up_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	if not _event.is_pressed():
		return false
	GameManager.board.set_input_state(Board.InputState.ALTERNATE_UP, up_sprite.texture)
	return true


func _on_down_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	if not _event.is_pressed():
		return false
	GameManager.board.set_input_state(Board.InputState.ALTERNATE_DOWN, down_sprite.texture)
	return true


func _on_left_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	if not _event.is_pressed():
		return false
	GameManager.board.set_input_state(Board.InputState.ALTERNATE_LEFT, left_sprite.texture)
	return true


func _on_right_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	if not _event.is_pressed():
		return false
	GameManager.board.set_input_state(Board.InputState.ALTERNATE_RIGHT, right_sprite.texture)
	return true


func _on_cancel_alternate_input_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	if not _event.is_pressed():
		return false
	if GameManager.board == null or not GameManager.board.is_in_alternate_input_state():
		return false
	GameManager.board.set_input_state(Board.InputState.NEUTRAL)
	return true
