extends Node2D
class_name DirectionPad


var areas: Dictionary = {
	Field.Direction.UP: null,
	Field.Direction.DOWN: null,
	Field.Direction.LEFT: null,
	Field.Direction.RIGHT: null
}
var sprites : Dictionary = {
	Field.Direction.UP: null,
	Field.Direction.DOWN: null,
	Field.Direction.LEFT: null,
	Field.Direction.RIGHT: null
}
var _registered_handlers: Dictionary = {}


func _ready() -> void:
	areas[Field.Direction.UP] = $Up/Area2D
	areas[Field.Direction.DOWN] = $Down/Area2D
	areas[Field.Direction.LEFT] = $Left/Area2D
	areas[Field.Direction.RIGHT] = $Right/Area2D
	sprites[Field.Direction.UP] = $Up/Sprite2D
	sprites[Field.Direction.DOWN] = $Down/Sprite2D
	sprites[Field.Direction.LEFT] = $Left/Sprite2D
	sprites[Field.Direction.RIGHT] = $Right/Sprite2D


func _enter_tree() -> void:
	call_deferred("_register_input_handlers")
	

func _exit_tree() -> void:
	var neutral_input_state := InputManager.get_input_state(InputState.InputStateType.BOARD_NEUTRAL)
	for direction in areas:
		var collider := areas[direction] as Area2D
		var handler := _registered_handlers[direction] as Callable
		neutral_input_state.deregister_mouse_button_event_handler(MOUSE_BUTTON_LEFT, collider, handler)


func _mouse_button_event_handler_gen(direction: Field.Direction, sprite_texture: Texture2D) -> Callable:
	return func(_collider: CollisionObject2D, _event: InputEventMouseButton) -> bool:
		if not _event.is_pressed():
			return false
		var alternate_input_state := InputState.new(
			InputState.InputStateType.BOARD_PICK_ENGAGE_ROOMS,
			{
				"alternate_mouse_cursor": sprite_texture,
				"custom_data": {
					"direction": direction
				}
			}
		)
		for room in GameManager.board.field.rooms:
			alternate_input_state.register_mouse_button_event_handler(
				MOUSE_BUTTON_LEFT,
				room.area,
				_on_pick_engage_rooms_mouse_left_click_room
			)
		alternate_input_state.register_fallback_mouse_button_event_handler(
			MOUSE_BUTTON_RIGHT,
			func(_collider2: CollisionObject2D, event: InputEventMouseButton) -> bool:
				if not event.is_pressed():
					return false
				InputManager.pop_input_state()
				return true
		)
		InputManager.register_input_state(alternate_input_state)
		InputManager.push_input_state(alternate_input_state)
		return true
		

func _register_input_handlers():
	var neutral_input_state := InputManager.get_input_state(InputState.InputStateType.BOARD_NEUTRAL)	
	_registered_handlers.clear()
	for direction in areas:
		var collider := areas[direction] as Area2D
		var sprite := sprites[direction] as Sprite2D
		var handler := _mouse_button_event_handler_gen(direction, sprite.texture)
		neutral_input_state.register_mouse_button_event_handler(MOUSE_BUTTON_LEFT, collider, handler)
		_registered_handlers[direction] = handler


func _on_pick_engage_rooms_mouse_left_click_room(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	if not event.is_pressed():
		return false
	var room := collider.get_parent() as Room
	if room == null:
		return false
	var field := GameManager.board.field
	var input_state := InputManager.current_input_state()
	var direction := input_state.context["direction"] as Field.Direction
	field.set_engaging_rooms_from(room, direction)
	InputManager.pop_input_state()
	return true