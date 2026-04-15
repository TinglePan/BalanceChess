extends Node2D
class_name Board


enum InputState {
	NEUTRAL,
	ALTERNATE_UP,
	ALTERNATE_DOWN,
	ALTERNATE_LEFT,
	ALTERNATE_RIGHT
}


@export var player_hand: PlayerHand
@export var field: Field
@export var main_camera: Camera2D
@export var card_manager: CardManager
@export var main_deck: Deck
@export var graveyard: Deck
@export var discard_pile: Deck
@export var encounter_deck: Deck

var level: int = 0
var input_state: InputState = InputState.NEUTRAL



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.board = self
	InputManager.ui_canvas_instance_id = $CanvasLayer.get_instance_id()


func _exit_tree() -> void:
	if GameManager.board == self:
		GameManager.board = null
	Input.set_custom_mouse_cursor(null)


func set_input_state(next_state: InputState, cursor_texture: Texture2D = null) -> void:
	input_state = next_state
	if input_state == InputState.NEUTRAL:
		Input.set_custom_mouse_cursor(null)
		return

	if cursor_texture == null:
		push_warning("Alternate input state set without a cursor texture.")
		return
	Input.set_custom_mouse_cursor(cursor_texture)


func is_in_alternate_input_state() -> bool:
	return input_state != InputState.NEUTRAL


func game_start() -> void:
	GameManager.player_data = PlayerData.new(3, 3, 3, 5)
	for i in range(5):
		main_deck.add_card_data(CardDb.MONSTER_CARDS["defect"])
	for i in range(5):
		main_deck.add_card_data(CardDb.MONSTER_CARDS["mob_slime"])
	for i in range(10):
		encounter_deck.add_card_data(CardDb.ITEM_CARDS["gold_nugget"])
	if main_camera != null:
		# Defer to ensure field nodes are fully laid out before fitting camera.
		main_camera.call_deferred("apply_initial_fit_zoom")
	level_start()
	
	
func level_start() -> void:
	level += 1
	field.set_grid_dimensions(level + 2, 3)
	reset()
	turn_start()
	
	
func reset() -> void:
	for room in field.rooms:
		for slot in room.player_lane.card_slots:
			if slot.pawn != null:
				slot.pawn.send_to_deck(main_deck)
		for slot in room.enemy_lane.card_slots:
			if slot.pawn != null:
				slot.pawn.send_to_deck(main_deck)
	for slot in field.bonus_slots:
		if slot.pawn != null:
			slot.pawn.send_to_deck(encounter_deck)
	for card in player_hand.cards:
		card.send_to_deck(main_deck)
	discard_pile.shuffle_to(main_deck)
	graveyard.shuffle_to(main_deck)


func turn_start() -> void:
	deal_enmey_cards()
	deal_bonus_cards()
	deal_player_hand_cards()
	

func turn_end() -> void:
	# TODO
	pass
	
	
func deal_enmey_cards():
	for room in field.rooms:
		var target_slot := room.enemy_lane.first_empty_slot()
		if target_slot != null:
			main_deck.deal_card(target_slot)
			
			
func deal_bonus_cards() -> void:
	for slot in field.bonus_slots:
		if slot.pawn != null:
			slot.pawn.send_to_deck(discard_pile)
	for slot in field.bonus_slots:
		if encounter_deck.card_data_list.is_empty():
			return
		encounter_deck.deal_card(slot)
		
			
func deal_player_hand_cards() -> void:
	var cards_needed := GameManager.player_data.base_hand_size - player_hand.cards.size()
	if cards_needed <= 0:
		return

	for i in range(cards_needed):
		if main_deck.card_data_list.is_empty():
			return
		main_deck.deal_card(player_hand)
