extends Node2D
class_name Field


@export var room_scene := preload("res://scenes/room.tscn") as PackedScene
@export var bonus_slot_scene := preload("res://scenes/bonus_slot.tscn") as PackedScene


var row_count: int = 0
var column_count: int = 0
var rooms: Array[Room] = []
var bonus_slots: Array[CardSlot] = []
var engaging_rooms: Array[Room] = []
@export var horizontal_spacing_px: float = 16
@export var vertical_spacing_px: float = 24


func get_boundary() -> Rect2:
	var merged := Rect2(global_position, Vector2.ZERO)
	var has_bounds := false

	for room_node in rooms:
		var room := room_node as Node2D
		var room_bounds := _get_node_bounds(room)
		if has_bounds:
			merged = merged.merge(room_bounds)
		else:
			merged = room_bounds
			has_bounds = true

	for bonus_node in bonus_slots:
		var bonus := bonus_node as Node2D
		var bonus_bounds := _get_node_bounds(bonus)
		if has_bounds:
			merged = merged.merge(bonus_bounds)
		else:
			merged = bonus_bounds
			has_bounds = true

	if not has_bounds:
		return Rect2(global_position, Vector2.ZERO)

	return merged


# update the number of the row_count and column_count. Also maintains the rooms array at the same time. The rooms array contains room instances and is an array functioning as a 2d array and rooms in the same row are adjacent to each other in this array. The rooms array may already has some elements before calling this function. Adjust the elements of this array so it matches the row and column count. Add new rooms if the size grows and remove old rooms if the size shrinks. The positioning of these rooms is taken care of by another function called adjust_room_positions, call this whenever the field size changes.
func set_grid_dimensions(_row_count: int, _column_count: int) -> void:
	row_count = max(_row_count, 0)
	column_count = max(_column_count, 0)
	_sync_room_count()
	_sync_bonus_slot_count()
	_adjust_room_positions()
	
	
func resolve_battle() -> void:
	for room_node in engaging_rooms:
		var room := room_node as Room
		room.resolve_battle()
	clear_engaging_rooms()
	if is_all_clear():
		GameManager.board.round_start()
	
	
func is_all_clear() -> bool:
	for room_node in rooms:
		var room := room_node as Room
		if not room.enemy_lane.is_empty():
			return false
	return true
		
		
func room_index(room: Room) -> Vector2i:
	if room == null or column_count <= 0:
		return Vector2i(-1, -1)

	var index := rooms.find(room)
	if index < 0:
		return Vector2i(-1, -1)

	var column := index % column_count
	var row := floori(float(index) / float(column_count))
	return Vector2i(column, row)


func set_engaging_rooms_from(room: Room) -> void:
	var ordered_rooms: Array[Room] = []
	if room == null or row_count <= 0 or column_count <= 0:
		return 

	var start_index := room_index(room)
	if start_index.x < 0 or start_index.y < 0:
		return

	match GameManager.board.current_input_state.id:
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_LEFT:
			for column in range(column_count - 1, -1, -1):
				_add_room_at(column, start_index.y, ordered_rooms)
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_RIGHT:
			for column in range(column_count):
				_add_room_at(column, start_index.y, ordered_rooms)
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_UP:
			for row in range(row_count - 1, -1, -1):
				_add_room_at(start_index.x, row, ordered_rooms)
		InputState.InputStateId.BOARD_PICK_ENGAGE_ROOMS_DOWN:
			for row in range(row_count):
				_add_room_at(start_index.x, row, ordered_rooms)
		_:
			push_error("get_ordered_rooms_from called with non pick engage rooms input state, which is not valid for ordering rooms.")
	
	clear_engaging_rooms()
	
	for r in ordered_rooms:
		if r == null or engaging_rooms.has(r):
			continue
		engaging_rooms.append(r)
		r.set_engaging_index(engaging_rooms.size())
		
		
func clear_engaging_rooms() -> void:
	for r in engaging_rooms:
		if r != null:
			r.set_engaging_index(0)
	engaging_rooms.clear()


# Adjust rooms plus bonus headers. Row bonus cells are placed to the left of each row,
# and column bonus cells are placed above each column, both aligned to room centers.
func _adjust_room_positions() -> void:
	var room_count := rooms.size()
	if room_count == 0 or row_count <= 0 or column_count <= 0:
		return

	var room_template := rooms[0] as Room
	var room_size := room_template.get_size()
	var bonus_size := _get_bonus_slot_size()

	var room_step_x: float = room_size.x + horizontal_spacing_px
	var room_step_y: float = room_size.y + vertical_spacing_px
	var room_grid_width: float = float(column_count) * room_size.x + float(max(column_count - 1, 0)) * horizontal_spacing_px
	var layout_width: float = bonus_size.x + horizontal_spacing_px + room_grid_width
	var layout_left: float = $TopAnchor.global_position.x - layout_width * 0.5
	var row_bonus_x: float = layout_left + bonus_size.x * 0.5
	var first_room_x: float = layout_left + bonus_size.x + horizontal_spacing_px + room_size.x * 0.5

	var column_bonus_y: float = $TopAnchor.global_position.y
	var first_room_y: float = column_bonus_y + bonus_size.y * 0.5 + vertical_spacing_px + room_size.y * 0.5

	for row in range(row_count):
		for column in range(column_count):
			var index := row * column_count + column
			if index < rooms.size():
				var room := rooms[index] as Room
				var x: float = first_room_x + float(column) * room_step_x
				var y: float = first_room_y + float(row) * room_step_y
				room.global_position = Vector2(x, y)

	for row in range(row_count):
		if row < bonus_slots.size():
			var row_bonus := bonus_slots[row]
			var y: float = first_room_y + float(row) * room_step_y
			row_bonus.global_position = Vector2(row_bonus_x, y)

	for column in range(column_count):
		var index := row_count + column
		if index < bonus_slots.size():
			var column_bonus := bonus_slots[index]
			var x: float = first_room_x + float(column) * room_step_x
			column_bonus.global_position = Vector2(x, column_bonus_y)


func _sync_room_count() -> void:
	var target_size := row_count * column_count
	if rooms.size() < target_size:
		for i in range(rooms.size(), target_size):
			var new_room := room_scene.instantiate() as Room
			if new_room == null:
				push_error("Room scene did not instantiate a Room.")
				continue

			var room_clicked_handler := _on_room_clicked.bind(new_room)
			if not new_room.clicked.is_connected(room_clicked_handler):
				new_room.clicked.connect(room_clicked_handler)
			add_child(new_room)
			rooms.append(new_room)
	elif rooms.size() > target_size:
		for i in range(rooms.size() - 1, target_size - 1, -1):
			var room := rooms[i] as Room
			if room != null:
				engaging_rooms.erase(room)
			if room.get_parent() == self:
				remove_child(room)
			room.queue_free()
			rooms.remove_at(i)


func _sync_bonus_slot_count() -> void:
	var target_size := row_count + column_count
	if bonus_slots.size() < target_size:
		for i in range(bonus_slots.size(), target_size):
			var new_bonus := bonus_slot_scene.instantiate() as Node2D
			add_child(new_bonus)
			bonus_slots.append(new_bonus)
	elif bonus_slots.size() > target_size:
		for i in range(bonus_slots.size() - 1, target_size - 1, -1):
			var bonus := bonus_slots[i]
			if bonus.get_parent() == self:
				remove_child(bonus)
			bonus.queue_free()
			bonus_slots.remove_at(i)


func _get_bonus_slot_size() -> Vector2:
	if bonus_slots.is_empty():
		return Vector2.ZERO
	return _get_collision_shape_size(bonus_slots[0])


func _get_node_bounds(node: Node2D) -> Rect2:
	var size := _get_collision_shape_size(node)
	if size == Vector2.ZERO:
		return Rect2(node.global_position, Vector2.ZERO)

	var center := node.global_position
	var area := node.get_node_or_null("Area2D") as Area2D
	if area != null:
		var collision_shape := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision_shape != null:
			center = collision_shape.global_position

	return Rect2(center - size * 0.5, size)


func _get_collision_shape_size(node: Node2D) -> Vector2:
	var area := node.get_node_or_null("Area2D") as Area2D
	if area == null:
		return Vector2.ZERO

	var collision_shape := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return Vector2.ZERO

	var rect_shape := collision_shape.shape as RectangleShape2D
	if rect_shape == null:
		return Vector2.ZERO

	return rect_shape.size * collision_shape.global_scale.abs()


func _add_room_at(column: int, row: int, target: Array[Room]) -> void:
	var linear_index := row * column_count + column
	if linear_index < 0 or linear_index >= rooms.size():
		return

	var room := rooms[linear_index] as Room
	if room != null:
		target.append(room)
	
	
func _on_room_clicked(room: Room) -> void:
	if room == null:
		return


# On Start Button Pressed, for testing purposes only. This will resolve the battle in all engaging rooms and print the result to the console.
func _on_button_pressed():
	resolve_battle()
