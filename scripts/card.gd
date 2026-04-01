extends Node2D
class_name Card


const COLLISION_MASK := 1
const NORMAL_Z_INDEX := 1
const HIGHLIGHT_Z_INDEX := NORMAL_Z_INDEX + 100
const DRAG_Z_INDEX := HIGHLIGHT_Z_INDEX + 100


var data: CardData
var can_drag: bool = true
var area_size: Vector2
var drag_start_pos: Vector2
var current_holder: Node2D = null


func _ready() -> void:
	var collision_shape := $Area2D/CollisionShape2D
	var rect_shape := collision_shape.shape as RectangleShape2D
	area_size = rect_shape.size * collision_shape.global_scale.abs()
	

func _on_area_2d_mouse_entered():
	GameManager.card_manager.hover_over(self)


func _on_area_2d_mouse_exited():
	GameManager.card_manager.hover_off(self)
	
	
func load_data(card_data: CardData):
	data = card_data
	$Sprite.texture = load(data.sprite_path)
	$Name.text = data.name
	$Rank.text = str(data.rank)


func animate_move(to_position: Vector2, duration: float = 0.2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", to_position, duration)
	
	
func toggle_highlight(highlight: bool) -> void:
	if highlight:
		scale = Vector2(1.05, 1.05) # Example of highlighting by scaling up the card
		z_index = HIGHLIGHT_Z_INDEX # Bring the card to the front
	else:
		scale = Vector2(1, 1) # Reset scale
		z_index = NORMAL_Z_INDEX


func on_start_drag():
	drag_start_pos = global_position
	scale = Vector2(1.1, 1.1) # Example of dragging by scaling up the card
	z_index = DRAG_Z_INDEX
