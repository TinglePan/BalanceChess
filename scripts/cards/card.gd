extends Node2D
class_name Card


signal mouse_entered
signal mouse_exited
signal drag_started


const COLLISION_MASK := 1
const NORMAL_Z_INDEX := 1
const HIGHLIGHT_Z_INDEX := NORMAL_Z_INDEX + 100
const DRAG_Z_INDEX := HIGHLIGHT_Z_INDEX + 100
const DRAG_BUTTON := MOUSE_BUTTON_LEFT


var data: CardData
var logic: CardLogic
var can_drag: bool = true
var area_size: Vector2
var drag_start_pos: Vector2
var current_holder: Node2D


func _ready() -> void:
	var collision_shape := $Area2D/CollisionShape2D
	var rect_shape := collision_shape.shape as RectangleShape2D
	area_size = rect_shape.size * collision_shape.global_scale.abs()
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.register_mouse_button_event_handler(DRAG_BUTTON, $Area2D, _on_mouse_button_event)
	

func _on_area_2d_mouse_entered():
	mouse_entered.emit()


func _on_area_2d_mouse_exited():
	mouse_exited.emit()
	
	
func load_data(card_data: CardData):
	data = card_data
	$Sprite.texture = load(data.sprite_path)
	$Name.text = data.name
	if card_data.type in CardData.CARD_TYPES_WITH_RANK:
		$Rank.visible = true		
		$Rank.text = str(data.rank)
	else:
		$Rank.visible = false
	logic = CardDb.create_card_logic(data)
	logic.set_owner(self)


func get_logic() -> CardLogic:
	return logic


func animate_move(to_position: Vector2, duration: float = 0.2) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "global_position", to_position, duration)
	return tween
	
	
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


func _on_mouse_button_event(_collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
	if event.pressed and can_drag:
		drag_started.emit()
		return true
	return false
