extends Camera2D
class_name MainCamera


const zoom_min := Vector2(0.5, 0.5)
const zoom_max := Vector2(2, 2)
const zoom_speed := 0.1

const DRAG_BUTTON := MOUSE_BUTTON_RIGHT
const boundary_margin := 50.0


var dragging: bool = false
var field: Field
var initial_zoom_scalar: float = 1.0


func _ready() -> void:
	field = get_parent().get_node("Field") as Field
	apply_initial_fit_zoom()
	InputManager.register_mouse_button_event_handler(DRAG_BUTTON, null, on_drag_button_event)
	InputManager.register_mouse_motion_event_handler(DRAG_BUTTON, on_mouse_motion)
	InputManager.register_mouse_button_event_handler(MouseButton.MOUSE_BUTTON_WHEEL_DOWN, null, on_mouse_wheel_down)
	InputManager.register_mouse_button_event_handler(MouseButton.MOUSE_BUTTON_WHEEL_UP, null, on_mouse_wheel_up)


func _exit_tree() -> void:
	InputManager.deregister_mouse_button_event_handler(DRAG_BUTTON, null, on_drag_button_event)
	InputManager.deregister_mouse_motion_event_handler(DRAG_BUTTON, on_mouse_motion)
	InputManager.deregister_mouse_button_event_handler(MouseButton.MOUSE_BUTTON_WHEEL_DOWN, null, on_mouse_wheel_down)
	InputManager.deregister_mouse_button_event_handler(MouseButton.MOUSE_BUTTON_WHEEL_UP, null, on_mouse_wheel_up)
	

func on_mouse_wheel_up(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	apply_zoom(zoom_speed)
	return false
	
	
func on_mouse_wheel_down(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	apply_zoom(-zoom_speed)
	return false
	
	
func on_drag_button_event(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	dragging = event.pressed
	return false


func on_mouse_motion(event: InputEventMouseMotion) -> bool:
	if not dragging:
		return true
	drag(event.relative)
	return false


func apply_zoom(delta: float) -> void:
	var current_zoom_scalar: float = zoom.x
	var target_zoom_scalar: float = current_zoom_scalar + delta
	var current_offset_from_initial: float = current_zoom_scalar - initial_zoom_scalar
	var target_offset_from_initial: float = target_zoom_scalar - initial_zoom_scalar

	# Snap only when the step crosses initial zoom from one side to the other.
	if current_offset_from_initial * target_offset_from_initial < 0.0:
		target_zoom_scalar = initial_zoom_scalar

	zoom = clamp_zoom_to_boundary(Vector2.ONE * target_zoom_scalar)
	clamp_to_field()


func drag(delta: Vector2) -> void:
	set_camera_center(clamp_view_center(get_camera_center() - delta / zoom, zoom))


func apply_initial_fit_zoom() -> void:
	var fit_zoom: float = get_fit_zoom_scalar()
	zoom = clamp_zoom_to_boundary(Vector2.ONE * fit_zoom)
	initial_zoom_scalar = zoom.x
	clamp_to_field()


func get_fit_zoom_scalar() -> float:
	var min_allowed_zoom := get_min_allowed_zoom()
	var boundary_fit_zoom: float = maxf(min_allowed_zoom.x, min_allowed_zoom.y)
	var max_zoom_limit: float = maxf(zoom_max.x, zoom_max.y)
	return minf(boundary_fit_zoom, max_zoom_limit)


func clamp_zoom_to_boundary(next_zoom: Vector2) -> Vector2:
	var min_allowed_zoom := get_min_allowed_zoom()
	var boundary_min_zoom: float = maxf(min_allowed_zoom.x, min_allowed_zoom.y)
	var max_zoom_limit: float = maxf(zoom_max.x, zoom_max.y)
	var uniform_min_zoom: float = minf(boundary_min_zoom, max_zoom_limit)
	var uniform_max_zoom: float = max_zoom_limit
	var requested_zoom: float = (next_zoom.x + next_zoom.y) * 0.5
	var clamped_zoom: float = clampf(requested_zoom, uniform_min_zoom, uniform_max_zoom)
	return Vector2.ONE * clamped_zoom


func get_effective_boundary() -> Rect2:
	var boundary := field.get_boundary()
	if boundary_margin <= 0.0:
		return boundary
	return Rect2(
		boundary.position - Vector2.ONE * boundary_margin,
		boundary.size + Vector2.ONE * boundary_margin * 2.0
	)


func get_min_allowed_zoom() -> Vector2:
	var min_allowed_zoom := zoom_min
	var boundary := get_effective_boundary()
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
	var boundary := get_effective_boundary()
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
