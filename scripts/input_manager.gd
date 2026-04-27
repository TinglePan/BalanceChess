extends Node2D

const DEFAULT_COLLISION_LAYER := 1


var ui_canvas_instance_id: int

var input_states: Dictionary[InputState.InputStateId, InputState] = {}
var input_state_stack: Array[InputState]


func current_input_state() -> InputState:
	return input_state_stack.back() if input_state_stack.size() > 0 else null


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		current_input_state().dispatch_mouse_button_event(event)
	elif event is InputEventMouseMotion:
		current_input_state().dispatch_mouse_motion_event(event)
		
		
func register_input_state(state: InputState) -> void:
	if state.id in input_states:
		push_warning("Input state with id %d is already registered" % state.id)
	input_states[state.id] = state
	
	
func get_input_state(state_id: InputState.InputStateId) -> InputState:
	if state_id in input_states:
		return input_states[state_id]
	push_error("Input state with id %d is not registered" % state_id)
	return null
		
		
func push_input_state(next_state: InputState) -> void:
	var prev_state := current_input_state()
	if prev_state.id == next_state.id:
		return
	if prev_state != null:
		prev_state.on_exit()
	input_state_stack.append(next_state)
	if next_state != null:
		next_state.on_enter()
		
		
func pop_input_state() -> void:
	if input_state_stack.size() == 0:
		return
	var prev_state := current_input_state()
	input_state_stack.pop_back()
	var next_state := current_input_state()
	if prev_state != null:
		prev_state.on_exit()
	if next_state != null:
		next_state.on_enter()


func raycast_topmost(pos: Vector2, canvas_instance_id_list: Array[int], mask: int) -> Node2D:
	var result := raycast_colliders_sorted(pos, canvas_instance_id_list, mask)
	var size := result.size()
	if size > 0:
		return result[0]
	return null


func raycast_colliders_sorted(pos: Vector2, canvas_instance_id_list: Array[int], mask: int) -> Array[CollisionObject2D]:
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