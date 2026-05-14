extends InputState
class_name ConfirmableInputState


var confirm_checks: MultiLatch
var on_confirm_callback: Callable


func _init(_id: InputStateType, _args: Dictionary = {}) -> void:
	super._init(_id, _args)
	confirm_checks = _args.get("confirm_checks", null)
	on_confirm_callback = _args.get("on_confirm_callback", Callable())
	if confirm_checks != null:
		confirm_checks.all_checked.connect(_on_confirm_checks_all_checked)
	
	
func check(key: String) -> void:
	if confirm_checks != null and confirm_checks.has_check(key):
		confirm_checks.check(key)
		
		
func _on_confirm_checks_all_checked() -> void:
	if GameManager.allow_auto_confirm:
		if on_confirm_callback.is_valid():
			on_confirm_callback.call()
		InputManager.exit_input_state(self)