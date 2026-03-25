extends Node


var has_started := false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_started:
		has_started = true
		$Deck.add_card_data(CardDb.CARDS["defect"])
		$Deck.add_card_data(CardDb.CARDS["mob_slime"])
		$Deck.add_card_data(CardDb.CARDS["mob_slime"])
