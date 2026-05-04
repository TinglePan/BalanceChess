extends CardEffect
class_name ChangeRankEffect


var rank_mod: Callable


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	rank_mod = args.get("rank_mod", Callable())


func _execute(_payload: Dictionary = {}) -> void:
	if not rank_mod.is_valid():
		push_warning("ChangeRankEffect: rank_mod callable is not valid")
		return

	var pawn := card_logic.owner_node as Pawn
	if pawn == null or not is_instance_valid(pawn):
		return

	var data := card_logic.data as CardData
	if data == null:
		return

	data.rank_mods.append(rank_mod)
	if data.rank() != 0:
		return

	var pawn_slot := pawn.slot
	if pawn_slot == null or not is_instance_valid(pawn_slot):
		return
	if GameManager.board == null or GameManager.board.graveyard == null:
		return

	pawn_slot.send_pawn_to_deck(GameManager.board.graveyard)
