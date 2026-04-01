extends Node2D
class_name Field


@export var room_scene := preload("res://scenes/room.tscn") as PackedScene
@export var bonus_cell_scene := preload("res://scenes/bonus_cell.tscn") as PackedScene


var row_count: int
var column_count: int
var rooms: Array
var bonus_cells: Array
@export var horizontal_spacing_px: float = 16
@export var vertical_spacing_px: float = 24



func get_boundary() -> Rect2:
	if row_count <= 0 or column_count <= 0 or rooms.is_empty():
		return Rect2(global_position, Vector2.ZERO)

	var min_x: float = INF
	var min_y: float = INF
	var max_x: float = -INF
	var max_y: float = -INF

	for room_node in rooms:
		var room := room_node as Room
		var half_room := room.get_size() * 0.5
		var room_center := room.global_position
		min_x = min(min_x, room_center.x - half_room.x)
		max_x = max(max_x, room_center.x + half_room.x)
		min_y = min(min_y, room_center.y - half_room.y)
		max_y = max(max_y, room_center.y + half_room.y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))


# update the number of the row_count and column_count. Also maintains the rooms array at the same time. The rooms array contains room instances and is an array functioning as a 2d array and rooms in the same row are adjacent to each other in this array. The rooms array may already has some elements before calling this function. Adjust the elements of this array so it matches the row and column count. Add new rooms if the size grows and remove old rooms if the size shrinks. The positioning of these rooms is taken care of by another function called adjust_room_positions, call this whenever the field size changes.
func set_grid_dimensions(_row_count: int, _column_count: int) -> void:
	row_count = _row_count
	column_count = _column_count
	var new_size := row_count * column_count
	if rooms.size() < new_size:
		for i in range(rooms.size(), new_size):
			var new_room := room_scene.instantiate() as Node2D
			add_child(new_room)
			rooms.append(new_room)
	elif rooms.size() > new_size:
		for i in range(rooms.size() - 1, new_size - 1, -1):
			remove_child(rooms[i])
			rooms[i].queue_free()
			rooms.remove_at(i)
	adjust_room_positions()
	

# adjust the position of the rooms. The rooms are layout in a grid manner. The first row is at the top center of the room. The elements of the first row is also centered. The top position is indicated with a child node named "TopAnchor", which can be accessed by $TopAnchor. The columns and the rows should have a configurable gapping which is an exported variable in Field class. The size of a room can be accessed by calling get_size() on the first room. 
func adjust_room_positions() -> void:
	var room_count := rooms.size()
	if room_count == 0:
		return
	var room_template := rooms[0] as Room
	var room_size := room_template.get_size()
	for row in range(row_count):
		for column in range(column_count):
			var index := row * column_count + column
			if index < rooms.size():
				var room := rooms[index] as Room
				var x := $TopAnchor.global_position.x + (column - (column_count - 1) * 0.5) * (room_size.x + horizontal_spacing_px) as float
				var y := $TopAnchor.global_position.y + row * (room_size.y + vertical_spacing_px) as float
				room.global_position = Vector2(x, y)