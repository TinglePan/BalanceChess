extends Node


var has_started := false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not has_started:
		has_started = true
		var board := GameManager.board as Board
		board.game_start()
