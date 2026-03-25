extends Node2D
class_name PlayerHand


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
	GameManager.player_hand_ref = self


func _exit_tree() -> void:
	if GameManager.player_hand_ref == self:
		GameManager.player_hand_ref = null


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
		
		
func update_card_positions(animation_duration: float = ANIMATION_DURATION):
	for i in cards.size():
		cards[i].animate_move(calculate_card_position(i), animation_duration)
		
		
func calculate_card_position(index: int) -> Vector2:
	var hand_rect_center := rect.get_center()
	
	var card_count := cards.size()
	var x := hand_rect_center.x
	var y := hand_rect_center.y
	if card_count <= 1:
		return Vector2(x, y)
		
	var card_width := cards[0].area_size.x
	var left_x := rect.position.x + (card_width * 0.5)
	var clamped_index := clampi(index, 0, card_count - 1)
	var max_x_span: float = maxf(0.0, rect.size.x - card_width)
	var spacing: float = max_x_span / float(card_count - 1)
	x = left_x + (spacing * clamped_index)
	return Vector2(x, y)
