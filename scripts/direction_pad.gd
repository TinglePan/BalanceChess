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

var _input_state_ids: Array[InputState.InputStateId] = [
	InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_UP, 
	InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_DOWN, 
	InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_LEFT, 
	InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_RIGHT
]
var _colliders: Array[Area2D] = [up_area, down_area, left_area, right_area]
var _sprites: Array[Sprite2D] = [up_sprite, down_sprite, left_sprite, right_sprite]
var _registered_left_click_handlers: Array[Callable] = []


func _ready() -> void:
	var neutral_input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)	
	_registered_left_click_handlers.clear()
	for i in range(_input_state_ids.size()):
		var input_state_id := _input_state_ids[i] as InputState.InputStateId
		var sprite := _sprites[i] as Sprite2D
		var collider := _colliders[i] as Area2D
		var handler := _mouse_button_event_handler_gen(input_state_id, sprite.texture)
		neutral_input_state.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, collider, handler)
		var alternate_input_state := InputManager.get_input_state(input_state_id)
		alternate_input_state.register_fallback_mouse_button_event_handler(MOUSE_BUTTON_RIGHT, _on_cancel_alternate_input_event)
		_registered_left_click_handlers.append(handler)
	

func _exit_tree() -> void:
	var neutral_input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	for i in range(_input_state_ids.size()):
		var input_state_id := _input_state_ids[i]
		var collider := _colliders[i]
		var handler := _registered_left_click_handlers[i]
		neutral_input_state.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, collider, handler)
		var alternate_input_state := InputManager.get_input_state(input_state_id)
		alternate_input_state.deregister_fallback_mouse_button_event_handler(MOUSE_BUTTON_RIGHT, _on_cancel_alternate_input_event)
	_registered_left_click_handlers.clear()


func _mouse_button_event_handler_gen(target_input_state: InputState.InputStateId, sprite_texture: Texture2D) -> Callable:
	return func(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
		if not _event.is_pressed():
			return false
		var alternate_input_state := InputManager.get_input_state(target_input_state)
		GameManager.board.set_input_state(alternate_input_state, sprite_texture)
		return true


func _on_cancel_alternate_input_event(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
	if not _event.is_pressed():
		return false
	InputManager.pop_input_state()
	return true
