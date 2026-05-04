extends RefCounted
class_name InputState


enum InputStateId {
	BOARD_NEUTRAL,
	BOARD_PICK_ENGAGE_ROOMS_UP,
	BOARD_PICK_ENGAGE_ROOMS_DOWN,
	BOARD_PICK_ENGAGE_ROOMS_LEFT,
	BOARD_PICK_ENGAGE_ROOMS_RIGHT,
	BOARD_MOVE_PICK_SLOT,
	BOARD_MOVE_PICK_SLOT_CARRIER,
}

enum InputEventId {
	MOUSE_BUTTON,
	MOUSE_MOTION
}

const UNHANDLED_EVENT_COLLIDER_ID := &"_unhandled"
const MOTION_BUTTONS := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]


var event_handlers := {
	InputEventId.MOUSE_BUTTON: {
		MOUSE_BUTTON_LEFT: {UNHANDLED_EVENT_COLLIDER_ID: []},
		MOUSE_BUTTON_MIDDLE: {UNHANDLED_EVENT_COLLIDER_ID: []},
		MOUSE_BUTTON_RIGHT: {UNHANDLED_EVENT_COLLIDER_ID: []},
		MOUSE_BUTTON_WHEEL_UP: {UNHANDLED_EVENT_COLLIDER_ID: []},
		MOUSE_BUTTON_WHEEL_DOWN: {UNHANDLED_EVENT_COLLIDER_ID: []}
	},
	InputEventId.MOUSE_MOTION: {
		MOUSE_BUTTON_LEFT: [],
		MOUSE_BUTTON_MIDDLE: [],
		MOUSE_BUTTON_RIGHT: []
	}
}

var id: InputStateId = InputStateId.BOARD_NEUTRAL
var canvas_id_list: Array[int]
var alternate_mouse_cursor: Texture2D = null


func _init(_id: InputStateId, _canvas_id_list: Array[int], _alternate_mouse_cursor: Texture2D = null) -> void:
	id = _id
	canvas_id_list = _canvas_id_list
	alternate_mouse_cursor = _alternate_mouse_cursor


func register_mouse_button_event_handler(button_index: int, collider: CollisionObject2D = null, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[InputEventId.MOUSE_BUTTON]:
		if not handler.is_valid():
			push_error("Cannot register invalid handler for mouse button index: %d" % button_index)
			return

		if collider == null:
			push_error("Collider is null for mouse button index: %d" % button_index)
			return
		event_handlers[InputEventId.MOUSE_BUTTON][button_index][collider.get_instance_id()] = handler
	else:
		push_error("Invalid mouse button index: %d" % button_index)
		

func register_fallback_mouse_button_event_handler(button_index: int, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[InputEventId.MOUSE_BUTTON]:
		if not handler.is_valid():
			push_error("Cannot register invalid default handler for mouse button index: %d" % button_index)
			return

		event_handlers[InputEventId.MOUSE_BUTTON][button_index][UNHANDLED_EVENT_COLLIDER_ID].append(handler)
	else:
		push_error("Invalid mouse button index: %d" % button_index)
		
	
func deregister_mouse_button_event_handler(button_index: int, collider: CollisionObject2D = null, handler: Callable = Callable()) -> void:
	MyLogger.print_formatted_log("Attempting to deregister mouse button event handler for button index %d, collider id %s" % [button_index, str(collider.get_instance_id())] )
	if button_index in event_handlers[InputEventId.MOUSE_BUTTON]:
		if collider == null:
			if handler.is_valid():
				event_handlers[InputEventId.MOUSE_BUTTON][button_index][UNHANDLED_EVENT_COLLIDER_ID].erase(handler)
			else:
				event_handlers[InputEventId.MOUSE_BUTTON][button_index][UNHANDLED_EVENT_COLLIDER_ID].clear()
		else:
			event_handlers[InputEventId.MOUSE_BUTTON][button_index].erase(collider.get_instance_id())
	else:
		push_error("Invalid mouse button index: %d" % button_index)
		
		
func deregister_fallback_mouse_button_event_handler(button_index: int, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[InputEventId.MOUSE_BUTTON]:
		if handler.is_valid():
			event_handlers[InputEventId.MOUSE_BUTTON][button_index][UNHANDLED_EVENT_COLLIDER_ID].erase(handler)
		else:
			event_handlers[InputEventId.MOUSE_BUTTON][button_index][UNHANDLED_EVENT_COLLIDER_ID].clear()
	else:
		push_error("Invalid mouse button index: %d" % button_index)


func register_mouse_motion_event_handler(button_index: int, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[InputEventId.MOUSE_MOTION]:
		if not handler.is_valid():
			push_error("Cannot register invalid handler for mouse motion button index: %d" % button_index)
			return

		event_handlers[InputEventId.MOUSE_MOTION][button_index].append(handler)
	else:
		push_error("Invalid mouse motion button index: %d" % button_index)


func deregister_mouse_motion_event_handler(button_index: int, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[InputEventId.MOUSE_MOTION]:
		if handler.is_valid():
			event_handlers[InputEventId.MOUSE_MOTION][button_index].erase(handler)
		else:
			event_handlers[InputEventId.MOUSE_MOTION][button_index].clear()
	else:
		push_error("Invalid mouse motion button index: %d" % button_index)


func on_enter() -> void:
	if alternate_mouse_cursor != null:
		Input.set_custom_mouse_cursor(alternate_mouse_cursor)
	
	
func on_exit() -> void:
	if alternate_mouse_cursor != null:
		Input.set_custom_mouse_cursor(null)


func dispatch_mouse_button_event(event: InputEventMouseButton) -> void:
	if event.button_index in event_handlers[InputEventId.MOUSE_BUTTON]:
		var handlers_for_button: Dictionary = event_handlers[InputEventId.MOUSE_BUTTON][event.button_index]
		if handlers_for_button.is_empty():
			return
			
		var colliders := InputManager.raycast_colliders_sorted(event.position, canvas_id_list, InputManager.DEFAULT_COLLISION_LAYER)
		for collider in colliders:
			var collider_id := collider.get_instance_id()
			if not handlers_for_button.has(collider_id):
				continue
	
			var handler: Callable = handlers_for_button[collider_id]
			if not handler.is_valid():
				handlers_for_button.erase(collider_id)
				continue
			MyLogger.print_formatted_log("Dispatching mouse button event to handler for collider %s" % collider_id)
			var result = handler.call(collider, event)
			if typeof(result) == TYPE_BOOL and result:
				return
			if typeof(result) != TYPE_BOOL:
				push_warning("Mouse handler for collider %s did not return bool; propagation continues by default." % str(collider))

		# Fallback handlers run only if collider handlers did not stop propagation.
		var fallback_handlers: Array = handlers_for_button.get(UNHANDLED_EVENT_COLLIDER_ID, [])
		var fallback_handlers_snapshot := fallback_handlers.duplicate()
		for handler_entry in fallback_handlers_snapshot:
			var fallback_handler: Callable = handler_entry
			if not fallback_handler.is_valid():
				fallback_handlers.erase(fallback_handler)
				continue

			var fallback_result = fallback_handler.call(null, event)
			if typeof(fallback_result) == TYPE_BOOL and fallback_result:
				return
			if typeof(fallback_result) != TYPE_BOOL:
				push_warning("Mouse fallback handler did not return bool; propagation continues by default.")


func dispatch_mouse_motion_event(event: InputEventMouseMotion) -> void:
	for button_index in MOTION_BUTTONS:
		if _is_mouse_button_pressed_in_mask(event.button_mask, button_index):
			if button_index not in event_handlers[InputEventId.MOUSE_MOTION]:
				push_error("No handlers registered for mouse button index: %d" % button_index)
				return
		
			var handlers_for_button: Array = event_handlers[InputEventId.MOUSE_MOTION][button_index]
			if handlers_for_button.is_empty():
				return
			
			var handlers_snapshot := handlers_for_button.duplicate()
			for handler_entry in handlers_snapshot:
				if not handler_entry.is_valid():
					handlers_snapshot.erase(handler_entry)
					continue
		
				var result = handler_entry.call(event)
				if typeof(result) == TYPE_BOOL and result:
					return
				if typeof(result) != TYPE_BOOL:
					push_warning("Mouse handler without collider did not return bool; propagation continues by default.")
			

func _is_mouse_button_pressed_in_mask(button_mask: int, button_index: int) -> bool:
	if button_index < 1:
		return false
	var mask_bit := 1 << (button_index - 1)
	return (button_mask & mask_bit) != 0
