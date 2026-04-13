extends Node2D
class_name DirectionPad


@onready var up_area: Area2D = $Up/Area2D
@onready var down_area: Area2D = $Down/Area2D
@onready var left_area: Area2D = $Left/Area2D
@onready var right_area: Area2D = $Right/Area2D


func _ready() -> void:
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, up_area, _on_up_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, down_area, _on_down_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, left_area, _on_left_mouse_button_event)
	InputManager.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, right_area, _on_right_mouse_button_event)


func _exit_tree() -> void:
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, up_area, _on_up_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, down_area, _on_down_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, left_area, _on_left_mouse_button_event)
	InputManager.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, right_area, _on_right_mouse_button_event)


func _on_up_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	# Intentionally empty for now.
	return false


func _on_down_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	# Intentionally empty for now.
	return false


func _on_left_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	# Intentionally empty for now.
	return false


func _on_right_mouse_button_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	# Intentionally empty for now.
	return false
