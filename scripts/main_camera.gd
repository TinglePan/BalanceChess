extends Camera2D
class_name MainCamera


const zoom_min := Vector2(1, 1)
const zoom_max := Vector2(2, 2)
const zoom_speed := 0.1

@export var drag_button := MOUSE_BUTTON_RIGHT

var field: Field


func _ready() -> void:
	field = get_parent().get_node("Field") as Field
	zoom = clamp_zoom_to_boundary(zoom)
	clamp_to_field()
	InputManager.mouse_wheel_up.connect(on_mouse_wheel_up)
	InputManager.mouse_wheel_down.connect(on_mouse_wheel_down)
	InputManager.mouse_dragged.connect(on_mouse_dragged)
	

func on_mouse_wheel_up():
	apply_zoom(zoom_speed)
	
	
	
func on_mouse_wheel_down():
	apply_zoom(-zoom_speed)


func apply_zoom(delta: float) -> void:
	zoom = clamp_zoom_to_boundary(zoom + Vector2.ONE * delta)
	clamp_to_field()


func drag(delta: Vector2) -> void:
	set_camera_center(clamp_view_center(get_camera_center() - delta / zoom, zoom))


func clamp_zoom_to_boundary(next_zoom: Vector2) -> Vector2:
	var min_allowed_zoom := get_min_allowed_zoom()
	var max_allowed_zoom := Vector2(
		max(zoom_max.x, min_allowed_zoom.x),
		max(zoom_max.y, min_allowed_zoom.y)
	)
	return Vector2(
		clampf(next_zoom.x, min_allowed_zoom.x, max_allowed_zoom.x),
		clampf(next_zoom.y, min_allowed_zoom.y, max_allowed_zoom.y)
	)


func get_min_allowed_zoom() -> Vector2:
	var min_allowed_zoom := zoom_min
	var boundary := field.get_boundary()
	var viewport_size := get_viewport().get_visible_rect().size

	if boundary.size.x > 0.0:
		min_allowed_zoom.x = max(min_allowed_zoom.x, viewport_size.x / boundary.size.x)
	if boundary.size.y > 0.0:
		min_allowed_zoom.y = max(min_allowed_zoom.y, viewport_size.y / boundary.size.y)

	return min_allowed_zoom


func get_view_size(camera_zoom: Vector2) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Vector2(
		viewport_size.x / max(camera_zoom.x, 0.001),
		viewport_size.y / max(camera_zoom.y, 0.001)
	)


func get_camera_center() -> Vector2:
	return global_position + offset


func set_camera_center(center: Vector2) -> void:
	offset = center - global_position


func clamp_to_field() -> void:
	set_camera_center(clamp_view_center(get_camera_center(), zoom))


func clamp_view_center(center: Vector2, camera_zoom: Vector2) -> Vector2:
	var boundary := field.get_boundary()
	var boundary_end := boundary.position + boundary.size
	var boundary_center := boundary.position + boundary.size * 0.5
	var half_view_size := get_view_size(camera_zoom) * 0.5
	var clamped_center := center

	if boundary.size.x <= 0.0 or half_view_size.x * 2.0 >= boundary.size.x:
		clamped_center.x = boundary_center.x
	else:
		clamped_center.x = clampf(center.x, boundary.position.x + half_view_size.x, boundary_end.x - half_view_size.x)

	if boundary.size.y <= 0.0 or half_view_size.y * 2.0 >= boundary.size.y:
		clamped_center.y = boundary_center.y
	else:
		clamped_center.y = clampf(center.y, boundary.position.y + half_view_size.y, boundary_end.y - half_view_size.y)

	return clamped_center


func on_mouse_dragged(button_index: int, delta: Vector2, _position: Vector2) -> void:
	if button_index != drag_button:
		return
	drag(delta)
