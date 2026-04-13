extends Node2D


const DEFAULT_COLLISION_LAYER := 1
const MOUSE_BUTTON_EVENT := &"InputEventMouseButton"
const MOUSE_MOTION_EVENT := &"InputEventMouseMotion"
const FALLBACK_HANDLERS_KEY := &"__fallback_handlers__"
const MOTION_BUTTONS := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]


var ui_canvas_instance_id: int
var event_handlers := {
	MOUSE_BUTTON_EVENT: {
		MOUSE_BUTTON_LEFT: {FALLBACK_HANDLERS_KEY: []},
		MOUSE_BUTTON_MIDDLE: {FALLBACK_HANDLERS_KEY: []},
		MOUSE_BUTTON_RIGHT: {FALLBACK_HANDLERS_KEY: []},
		MOUSE_BUTTON_WHEEL_UP: {FALLBACK_HANDLERS_KEY: []},
		MOUSE_BUTTON_WHEEL_DOWN: {FALLBACK_HANDLERS_KEY: []}
	},
	MOUSE_MOTION_EVENT: {
		MOUSE_BUTTON_LEFT: [],
		MOUSE_BUTTON_MIDDLE: [],
		MOUSE_BUTTON_RIGHT: []
	}
}


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_dispatch_mouse_button_event(event)
	elif event is InputEventMouseMotion:
		_dispatch_mouse_motion_event(event)
		

func register_mouse_button_event_handler(button_index: int, collider: CollisionObject2D = null, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[MOUSE_BUTTON_EVENT]:
		if not handler.is_valid():
			push_error("Cannot register invalid handler for mouse button index: %d" % button_index)
			return

		if collider == null:
			event_handlers[MOUSE_BUTTON_EVENT][button_index][FALLBACK_HANDLERS_KEY].append(handler)
		else:
			event_handlers[MOUSE_BUTTON_EVENT][button_index][collider.get_instance_id()] = handler
	else:
		push_error("Invalid mouse button index: %d" % button_index)
		
	
func deregister_mouse_button_event_handler(button_index: int, collider: CollisionObject2D = null, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[MOUSE_BUTTON_EVENT]:
		if collider == null:
			if handler.is_valid():
				event_handlers[MOUSE_BUTTON_EVENT][button_index][FALLBACK_HANDLERS_KEY].erase(handler)
			else:
				event_handlers[MOUSE_BUTTON_EVENT][button_index][FALLBACK_HANDLERS_KEY].clear()
		else:
			event_handlers[MOUSE_BUTTON_EVENT][button_index].erase(collider.get_instance_id())
	else:
		push_error("Invalid mouse button index: %d" % button_index)


func register_mouse_motion_event_handler(button_index: int, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[MOUSE_MOTION_EVENT]:
		if not handler.is_valid():
			push_error("Cannot register invalid handler for mouse motion button index: %d" % button_index)
			return

		event_handlers[MOUSE_MOTION_EVENT][button_index].append(handler)
	else:
		push_error("Invalid mouse motion button index: %d" % button_index)


func deregister_mouse_motion_event_handler(button_index: int, handler: Callable = Callable()) -> void:
	if button_index in event_handlers[MOUSE_MOTION_EVENT]:
		if handler.is_valid():
			event_handlers[MOUSE_MOTION_EVENT][button_index].erase(handler)
		else:
			event_handlers[MOUSE_MOTION_EVENT][button_index].clear()
	else:
		push_error("Invalid mouse motion button index: %d" % button_index)


func raycast_topmost(pos: Vector2, canvas_instance_id_list: Array[int], mask: int = DEFAULT_COLLISION_LAYER) -> Node2D:
	var result := raycast_colliders_sorted(pos, canvas_instance_id_list, mask)
	var size := result.size()
	if size > 0:
		return result[0]
	return null


func raycast_colliders_sorted(pos: Vector2, canvas_instance_id_list: Array[int], mask: int = DEFAULT_COLLISION_LAYER) -> Array[CollisionObject2D]:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = mask
	var colliders: Array[CollisionObject2D] = []
	for canvas_instance_id in canvas_instance_id_list:
		params.position = _viewport_to_canvas_position(pos, canvas_instance_id)
		params.canvas_instance_id = canvas_instance_id
		var hits := space_state.intersect_point(params)
		for hit in hits:
			var collider: CollisionObject2D = hit.collider
			if collider != null:
				colliders.append(collider)

	colliders.sort_custom(func (a: CollisionObject2D, b: CollisionObject2D):
		return _is_above(a, b)
	)
	return colliders


func _viewport_to_canvas_position(viewport_pos: Vector2, canvas_instance_id: int) -> Vector2:
	if canvas_instance_id == 0:
		return get_viewport().get_canvas_transform().affine_inverse() * viewport_pos
	return viewport_pos


func _is_above(a: CanvasItem, b: CanvasItem) -> bool:
	var a_layer := _get_canvas_layer(a)
	var b_layer := _get_canvas_layer(b)
	if a_layer != b_layer:
		return a_layer > b_layer

	var a_z := _get_effective_z_index(a)
	var b_z := _get_effective_z_index(b)
	if a_z != b_z:
		return a_z > b_z

	return _is_tree_order_after(a, b)


func _get_canvas_layer(item: CanvasItem) -> int:
	var current: Node = item
	while current != null:
		if current is CanvasLayer:
			return current.layer
		current = current.get_parent()
	return 0


func _get_effective_z_index(item: CanvasItem) -> int:
	var z := item.z_index
	if item.z_as_relative:
		var parent := item.get_parent()
		if parent is CanvasItem:
			z += _get_effective_z_index(parent)
	return z


func _get_tree_order_chain(node: Node) -> Array[int]:
	var chain: Array[int] = []
	var current: Node = node
	while current != null and current.get_parent() != null:
		chain.push_front(current.get_index())
		current = current.get_parent()
	return chain


func _is_tree_order_after(a: Node, b: Node) -> bool:
	var a_chain := _get_tree_order_chain(a)
	var b_chain := _get_tree_order_chain(b)
	var shared_depth := mini(a_chain.size(), b_chain.size())
	for i in shared_depth:
		if a_chain[i] != b_chain[i]:
			return a_chain[i] > b_chain[i]
	return a_chain.size() > b_chain.size()
		

func _dispatch_mouse_button_event(event: InputEventMouseButton) -> void:
	if event.button_index in event_handlers[MOUSE_BUTTON_EVENT]:
		var handlers_for_button: Dictionary = event_handlers[MOUSE_BUTTON_EVENT][event.button_index]
		if handlers_for_button.is_empty():
			return
			
		var colliders := raycast_colliders_sorted(event.position, [0, ui_canvas_instance_id], DEFAULT_COLLISION_LAYER)
		for collider in colliders:
			var collider_id := collider.get_instance_id()
			if not handlers_for_button.has(collider_id):
				continue
	
			var handler: Callable = handlers_for_button[collider_id]
			if not handler.is_valid():
				handlers_for_button.erase(collider_id)
				continue
	
			var result = handler.call(collider, event)
			if typeof(result) == TYPE_BOOL and result:
				return
			if typeof(result) != TYPE_BOOL:
				push_warning("Mouse handler for collider %s did not return bool; propagation continues by default." % str(collider))

		# Fallback handlers run only if collider handlers did not stop propagation.
		var fallback_handlers: Array = handlers_for_button.get(FALLBACK_HANDLERS_KEY, [])
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


func _dispatch_mouse_motion_event(event: InputEventMouseMotion) -> void:
	for button_index in MOTION_BUTTONS:
		if _is_mouse_button_pressed_in_mask(event.button_mask, button_index):
			if button_index not in event_handlers[MOUSE_MOTION_EVENT]:
				push_error("No handlers registered for mouse button index: %d" % button_index)
				return
		
			var handlers_for_button: Array = event_handlers[MOUSE_MOTION_EVENT][button_index]
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
	
