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

var _registered_handlers: Array = []


func _enter_tree() -> void:
	call_deferred("_register_input_handlers")
	

func _exit_tree() -> void:
	var neutral_input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	for entry in _registered_handlers:
		var collider := entry[0] as CollisionObject2D
		var handler := entry[1] as Callable
		neutral_input_state.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, collider, handler)
	_registered_handlers.clear()


func _mouse_button_event_handler_gen(target_input_state: InputState.InputStateId, sprite_texture: Texture2D) -> Callable:
	return func(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
		if not _event.is_pressed():
			return false
		var alternate_input_state := InputManager.get_input_state(target_input_state)
		GameManager.board.push_input_state(alternate_input_state, sprite_texture)
		return true
		

func _register_input_handlers():
	var neutral_input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)	
	_registered_handlers.clear()
	var input_state_ids := [
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_UP, 
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_DOWN, 
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_LEFT, 
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_RIGHT
	]
	var colliders: Array[Area2D] = [up_area, down_area, left_area, right_area]
	var sprites: Array[Sprite2D] = [up_sprite, down_sprite, left_sprite, right_sprite]
	for i in range(input_state_ids.size()):
		var input_state_id := input_state_ids[i] as InputState.InputStateId
		var collider := colliders[i] as Area2D
		var sprite := sprites[i] as Sprite2D
		var handler := _mouse_button_event_handler_gen(input_state_id, sprite.texture)
		neutral_input_state.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, collider, handler)
		_registered_handlers.append([collider, handler])
