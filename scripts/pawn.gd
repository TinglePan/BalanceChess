extends Node
class_name Pawn


var card_data: CardData


func load_card_data(_card_data: CardData):
	card_data = _card_data
	$Sprite2D.texture = load(card_data.sprite_path)
	$Rank.text = str(card_data.rank)