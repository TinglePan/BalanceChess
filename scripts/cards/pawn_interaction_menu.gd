extends Control
class_name PawnInteractionMenu


const BUTTON_SPACING := 8.0
const DEFAULT_BUTTON_SIZE := Vector2(32.0, 32.0)

var buttons: Array[TextureButton] = []


func _ready() -> void:
	visible = false


func open(effects: Array) -> void:
	_clear_buttons()
	for effect in effects:
		if effect == null:
			continue

		var button := TextureButton.new()
		var icon: Texture2D = null
		icon = load(effect.mini_icon_path) as Texture2D

		if icon != null:
			button.texture_normal = icon
			button.custom_minimum_size = icon.get_size()
		else:
			button.custom_minimum_size = DEFAULT_BUTTON_SIZE

		button.pressed.connect(_on_effect_button_pressed.bind(effect))
		add_child(button)
		buttons.append(button)

	if buttons.size() > 0:
		var total_width := -BUTTON_SPACING
		for button in buttons:
			total_width += button.custom_minimum_size.x + BUTTON_SPACING

		var next_x := -total_width * 0.5
		for button in buttons:
			button.position = Vector2(next_x, 0.0)
			next_x += button.custom_minimum_size.x + BUTTON_SPACING

	visible = true


func close() -> void:
	visible = false


func _clear_buttons() -> void:
	for button in buttons:
		if is_instance_valid(button):
			button.queue_free()
	buttons.clear()


func _on_effect_button_pressed(effect: CardEffect) -> void:
	effect.apply({})
