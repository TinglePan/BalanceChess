extends Node2D


signal mouse_left_button_pressed
signal mouse_left_button_released


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.pressed:
				mouse_left_button_pressed.emit()
			else:
				mouse_left_button_released.emit()


func raycast(pos) -> Node2D:
	var mask := Card.COLLISION_MASK | CardSlot.COLLISION_MASK | PlayerHand.COLLISION_MASK | Deck.COLLISION_MASK
	return raycast_with_mask(pos, mask)


func raycast_with_mask(pos: Vector2, mask) -> Node2D:
	var _sort_z_order := func (a, b):
		return int(b.collider.z_index) - int(a.collider.z_index)
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = true
	params.collision_mask = mask
	var result := space_state.intersect_point(params)
	var size := result.size()
	if size > 0:
		if size > 1:
			result.sort_custom(_sort_z_order)
		return result[0].collider
	return null
