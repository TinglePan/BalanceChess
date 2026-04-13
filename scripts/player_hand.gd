extends Node2D
class_name PlayerHand


@export var spacing: float = 24.0
var cards: Array[Card] = []

const COLLISION_MASK := 1 << 2
const ANIMATION_DURATION := 0.2


var rect: Rect2


func _ready() -> void:
	var collision_shape := $Area2D/CollisionShape2D
	var rect_shape := collision_shape.shape as RectangleShape2D
	var scaled_rect_size := rect_shape.size * collision_shape.global_scale.abs() as Vector2
	var top_left := collision_shape.global_position - (scaled_rect_size * 0.5) as Vector2
	rect = Rect2(top_left, scaled_rect_size)


func add_card(card: Card, index: int = 0, animation_duration: float = ANIMATION_DURATION):
	cards.insert(index, card)
	card.current_holder = self
	card.z_index = index
	update_card_positions(animation_duration)
	
	
func remove_card(card: Card):
	cards.erase(card)
	card.current_holder = null
	card.z_index = Card.NORMAL_Z_INDEX
	update_card_positions()
	
	
func send_card_to(deck: Deck, index: int = 0, animation_duration: float = ANIMATION_DURATION) -> void:
	if deck == null:
		push_error("Target deck is null")
		return
	if index < 0 or index >= cards.size():
		push_error("Invalid card index: ", index)
		return

	var card := cards[index]
	cards.remove_at(index)
	card.current_holder = null
	card.can_drag = false
	card.z_index = Card.DRAG_Z_INDEX
	update_card_positions(animation_duration)

	var tween := card.animate_move(deck.global_position, animation_duration)
	deck.add_card_data(card.data, -1)
	await tween.finished
	card.queue_free()
	
		
func update_card_positions(animation_duration: float = ANIMATION_DURATION):
	for i in cards.size():
		cards[i].animate_move(calculate_card_position(i), animation_duration)
		
		
func calculate_card_position(index: int) -> Vector2:
	var hand_rect_center := rect.get_center()
	
	var card_count := cards.size()
	var x := hand_rect_center.x
	var y := hand_rect_center.y
	
	if card_count == 0:
		return Vector2(x, y)
		
	var card_width := cards[0].area_size.x
	var left_x := rect.position.x + (card_width * 0.5)
	var clamped_index := clampi(index, 0, card_count - 1)
	var max_x_span: float = maxf(0.0, rect.size.x - card_width)
	var max_step_to_fit := max_x_span / float(card_count - 1) if card_count > 1 else 0.0
	var desired_step := card_width + spacing
	var step := minf(desired_step, max_step_to_fit)
	x = left_x + (step * clamped_index)
	return Vector2(x, y)
