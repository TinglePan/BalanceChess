extends Node2D


signal mouse_button_pressed(button_index)
signal mouse_button_released(button_index)
signal mouse_wheel_up
signal mouse_wheel_down
signal mouse_drag_started(button_index, position)
signal mouse_dragged(button_index, delta, position)
signal mouse_drag_ended(button_index, position)


const DEFAULT_COLLISION_LAYER := 1


var _is_dragging := false
var _drag_button := MouseButton.MOUSE_BUTTON_NONE
var ui_canvas_instance_id: int




func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP and event.pressed:
			mouse_wheel_up.emit()
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			mouse_wheel_down.emit()
		elif event.pressed:
			mouse_button_pressed.emit(event.button_index)
		else:
			mouse_button_released.emit(event.button_index)

		if event.button_index in [MouseButton.MOUSE_BUTTON_LEFT, MouseButton.MOUSE_BUTTON_MIDDLE, MouseButton.MOUSE_BUTTON_RIGHT]:
			if event.pressed:
				_is_dragging = true
				_drag_button = event.button_index
				mouse_drag_started.emit(_drag_button, event.position)
			elif _is_dragging and event.button_index == _drag_button:
				_is_dragging = false
				mouse_drag_ended.emit(_drag_button, event.position)
				_drag_button = MouseButton.MOUSE_BUTTON_NONE
	elif event is InputEventMouseMotion and _is_dragging:
		mouse_dragged.emit(_drag_button, event.relative, event.position)
		

func raycast(pos: Vector2, mask: int = 1, canvas_instance_id: int = 0) -> Node2D:
	var _sort_z_order := func (a, b):
		return int(b.collider.z_index) - int(a.collider.z_index)
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = true
	params.collision_mask = mask
	params.canvas_instance_id = canvas_instance_id
	var result := space_state.intersect_point(params)
	var size := result.size()
	if size > 0:
		if size > 1:
			result.sort_custom(_sort_z_order)
		return result[0].collider
	return null
