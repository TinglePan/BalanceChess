extends CardEffect
class_name ChangeRankEffect


var mod_type: CardBuffRankMod.MOD_TYPE
var duration_type: CardBuff.DURATION_TYPE
var mod_value: int
var max_target_pawns: int
var allow_repeat_targets: bool

var target_pawns: Array[Pawn]


func _init(_card_logic: CardLogic, args: Dictionary) -> void:
	super._init(_card_logic, args)
	mod_type = args.get("mod_type", CardBuffRankMod.MOD_TYPE.ADD)
	duration_type = args.get("duration_type", CardBuff.DURATION_TYPE.ALWAYS)
	mod_value = args.get("mod_value", 0)
	max_target_pawns = args.get("max_target_pawns", 1)
	allow_repeat_targets = args.get("allow_repeat_targets", false)
	target_pawns = []


func _play(payload: Dictionary = {}) -> void:
	target_pawns.clear()
	var input_state := _resolve_target_pawns_spec(payload, true)
	if input_state != null:
		InputManager.push_input_state(input_state)
	else:
		_execute_played(payload)


func _execute(_payload: Dictionary = {}) -> void:
	if target_pawns.is_empty():
		_resolve_target_pawns_spec(_payload, false)
	
	for pawn in target_pawns:
		if pawn == null or not is_instance_valid(pawn):
			continue

		var buff := CardBuffRankMod.new(
			self,
			duration_type,
			mod_type,
			mod_value
		)
		pawn.get_logic().add_buff(buff)

	target_pawns.clear()
	
	
func _resolve_target_pawns_spec(payload: Dictionary, can_pick) -> ConfirmableInputState:
	var target_pawns_spec := target_specs_by_key.get("target_pawns", null) as CardEffectTargetSpec
	if target_pawns_spec == null:
		push_warning("ChangeRankEffect: missing target spec for target_pawn")
		return null
	if target_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.SELF:
		var self_pawn := card_logic.owner_node as Pawn
		if self_pawn != null and is_instance_valid(self_pawn):
			target_pawns.append(self_pawn)
	if target_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE or target_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE_AND_PICK:
		var computed = target_pawns_spec.target_selector.call(self, payload)
		if computed is Array:
			for pawn in computed:
				if pawn is Pawn and is_instance_valid(pawn):
					target_pawns.append(pawn)
	if target_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.PICK or target_pawns_spec.targeting_mode == CardEffectTargetSpec.TargetingMode.COMPUTE_AND_PICK:
		var candidates: Array
		if target_pawns_spec.candidate_selector != null and target_pawns_spec.candidate_selector.is_valid():
			candidates = target_pawns_spec.candidate_selector.call(self, payload)
		else:
			push_warning("ChangeRankEffect: PICK_PAWNS target spec missing candidate selector")
			return
		
		return _add_select_targets_input_state(candidates, _on_pick_pawn, payload)
	return null
	

func _on_pick_pawn(pawn: Pawn, _input_state: InputState, payload: Dictionary) -> void:
	if pawn == null or not is_instance_valid(pawn):
		return
	if not allow_repeat_targets:
		var existing_index := target_pawns.find(pawn)
		if existing_index != -1:
			pawn.unpick()
			target_pawns.remove_at(existing_index)
			return
	if max_target_pawns > 0 and target_pawns.size() >= max_target_pawns:
		return
	pawn.pick()
	target_pawns.append(pawn)
	if target_pawns.size() >= max_target_pawns:
		_input_state.check("target_pawns")


func _on_enter_input_state():
	super._on_enter_input_state()
	for target_pawn in target_pawns:
		if target_pawn != null and is_instance_valid(target_pawn):
			target_pawn.pick()


func _on_exit_input_state():
	super._on_exit_input_state()
	for target_pawn in target_pawns:
		if target_pawn != null and is_instance_valid(target_pawn):
			target_pawn.unpick()
	target_pawns.clear()