extends Node
class_name Pawn


var card_data: CardData


func load_card_data(_card_data: CardData):
	card_data = _card_data
	$Sprite2D.texture = load(card_data.sprite_path)
	if card_data.type in CardData.CARD_TYPES_WITH_RANK:
		$Rank.visible = true		
		$Rank.text = str(card_data.rank)
	else:
		$Rank.visible = false
	
	
func animate_move(to_position: Vector2, duration: float = 0.2) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "global_position", to_position, duration)
	return tween
	
	
func send_to_deck(deck: Deck, index: int = 0, duration: float = 0.2):
	var tween := animate_move(deck.global_position, duration)
	tween.finished.connect(_on_sent_to_deck.bind(deck, index))
	
	
func _on_sent_to_deck(deck: Deck, index: int):
	deck.add_card_data(card_data, index)
	queue_free()
