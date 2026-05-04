extends Node2D
class_name Pawn


const INTERACT_BUTTON := MOUSE_BUTTON_LEFT


var slot: CardSlot = null
var card_data: CardData = null
var logic: CardLogic = null
@onready var interaction_menu: PawnInteractionMenu = $InteractionMenu
var area: Area2D


func _ready() -> void:
	slot = get_parent() as CardSlot
	area = $Area2D as Area2D
	
	
func _enter_tree() -> void:
	call_deferred("_register_mouse_input_handlers") # Defer to ensure Board is ready to receive input state registration
	MyLogger.print_formatted_log("Pawn: Registering mouse button event handler: %d" % $Area2D.get_instance_id())
	

func _exit_tree() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.deregister_mouse_button_event_handler(INTERACT_BUTTON, $Area2D, _on_mouse_button_event)
	MyLogger.print_formatted_log("Pawn: Deregistering mouse button event handler: %d" % $Area2D.get_instance_id())


func load_data(_card_data: CardData):
	card_data = _card_data
	$Sprite2D.texture = load(card_data.sprite_path)
	if card_data.type in CardData.CARD_TYPES_WITH_RANK:
		$Rank.visible = true		
		$Rank.text = str(card_data.rank)
	else:
		$Rank.visible = false
	logic = CardDb.create_card_logic(_card_data)
	logic.set_owner(self)


func get_logic() -> CardLogic:
	return logic
	
	
func animate_move(to_position: Vector2, duration: float = 0.2) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "global_position", to_position, duration)
	return tween
	
	
func send_to_deck(deck: Deck, index: int = 0, duration: float = 0.2):
	var tween := animate_move(deck.global_position, duration)
	tween.finished.connect(_on_sent_to_deck.bind(deck, index))


func on_focused():
	var action_phase_effects := _get_action_phase_effects()
	interaction_menu.open(action_phase_effects)
	
	
func on_unfocused():
	interaction_menu.close()

	
func _on_sent_to_deck(deck: Deck, index: int):
	deck.add_card_data(card_data, index)
	queue_free()


func _get_action_phase_effects() -> Array:
	if logic == null:
		return []
	return logic.get_effects_for_trigger(CardEffect.TriggerType.PLAY_ACTION_PHASE)
	
	
func _on_mouse_button_event(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
#	print("ev pressed: ", event.pressed, " ", collider)
#	print_stack()
	if event.pressed and event.button_index == INTERACT_BUTTON:
		MyLogger.print_formatted_log("pawn clicked with id: %d" % collider.get_instance_id())
		GameManager.board.card_manager.focus_pawn(self)
		return true
	return false


func _register_mouse_input_handlers() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateId.BOARD_NEUTRAL)
	input_state.register_mouse_button_event_handler(INTERACT_BUTTON, $Area2D, _on_mouse_button_event)