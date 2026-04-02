extends Node


var has_started := false

var main_deck: Deck


func _ready() -> void:
	$Field.set_grid_dimensions(2, 3)
	main_deck = $CanvasLayer.get_node("MainDeck")
	GameManager.main_camera = $Camera2D
	InputManager.ui_canvas_instance_id = $CanvasLayer.get_instance_id()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_started:
		has_started = true
		$Field.set_grid_dimensions(3, 3)
		main_deck.add_card_data(CardDb.CARDS["defect"])
		main_deck.add_card_data(CardDb.CARDS["mob_slime"])
		main_deck.add_card_data(CardDb.CARDS["mob_slime"])
		for i in range(10):
			main_deck.add_card_data(CardDb.CARDS["defect"])
