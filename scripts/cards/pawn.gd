extends Node2D
class_name Pawn


const INTERACT_BUTTON := MOUSE_BUTTON_LEFT


var slot: CardSlot
var logic: CardLogic
var interaction_menu: PawnInteractionMenu
var area: Area2D
var is_picked: bool
var pick_indicator: Sprite2D


func _ready() -> void:
	slot = get_parent() as CardSlot
	area = $Area2D as Area2D
	interaction_menu = $InteractionMenu as PawnInteractionMenu
	pick_indicator = $PickIndicator as Sprite2D
	unpick()
	
	
func _enter_tree() -> void:
	call_deferred("_register_mouse_input_handlers") # Defer to ensure Board is ready to receive input state registration
	MyLogger.print_formatted_log("Pawn: Registering mouse button event handler: %d" % $Area2D.get_instance_id())
	

func _exit_tree() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateType.BOARD_NEUTRAL)
	input_state.deregister_mouse_button_event_handler(INTERACT_BUTTON, $Area2D, _on_mouse_button_event)
	MyLogger.print_formatted_log("Pawn: Deregistering mouse button event handler: %d" % $Area2D.get_instance_id())


func load(_logic: CardLogic):
	logic = _logic
	$Sprite2D.texture = load(logic.data.sprite_path)
	if logic.data.type in CardData.CARD_TYPES_WITH_RANK:
		$Rank.visible = true		
		$Rank.text = str(logic.data.original_rank)
	else:
		$Rank.visible = false


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
	var play_effects := _get_play_effects()
	interaction_menu.open(play_effects)
	
	
func on_unfocused():
	interaction_menu.close()
	
	
func pick():
	is_picked = true
	pick_indicator.visible = true
	
	
func unpick():
	is_picked = false
	pick_indicator.visible = false

	
func _on_sent_to_deck(deck: Deck, index: int):
	deck.add_card_data(logic.data, index)
	queue_free()


func _get_play_effects() -> Array:
	if logic == null:
		return []
	var effects := logic.get_effects_for_trigger(CardEffect.TriggerType.PLAY_ACTION_PHASE)
	effects += logic.get_effects_for_trigger(CardEffect.TriggerType.PLAY_THEN_TRIGGER_TURN_END)
	return effects
	
	
func _on_mouse_button_event(collider: CollisionObject2D, event: InputEventMouseButton) -> bool:
#	print("ev pressed: ", event.pressed, " ", collider)
#	print_stack()
	if event.pressed and event.button_index == INTERACT_BUTTON:
		MyLogger.print_formatted_log("pawn clicked with id: %d" % collider.get_instance_id())
		GameManager.board.card_manager.focus_pawn(self)
		return true
	return false


func _register_mouse_input_handlers() -> void:
	var input_state := InputManager.get_input_state(InputState.InputStateType.BOARD_NEUTRAL)
	input_state.register_mouse_button_event_handler(INTERACT_BUTTON, $Area2D, _on_mouse_button_event)