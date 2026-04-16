extends RefCounted
class_name BoardEvents


const CARD_ENTERED_FIELD := &"board_card_entered_field"
const CARD_LEFT_FIELD := &"board_card_left_field"
const CARD_MOVED_BETWEEN_SLOTS := &"board_card_moved_between_slots"
const LEVEL_STARTED := &"board_level_started"
const TURN_STARTED := &"board_turn_started"
const TURN_ENDED := &"board_turn_ended"
const RESET := &"board_reset"


static var _listeners: Dictionary = {}


static func subscribe(event_name: StringName, callback: Callable) -> void:
	if event_name.is_empty() or not callback.is_valid():
		return
	var callbacks := _listeners.get(event_name, []) as Array[Callable]
	if callbacks.has(callback):
		return
	callbacks.append(callback)
	_listeners[event_name] = callbacks


static func unsubscribe(event_name: StringName, callback: Callable) -> void:
	if not _listeners.has(event_name):
		return
	var callbacks := _listeners[event_name] as Array[Callable]
	callbacks.erase(callback)
	if callbacks.is_empty():
		_listeners.erase(event_name)
	else:
		_listeners[event_name] = callbacks


static func publish(event_name: StringName, payload: Dictionary = {}) -> void:
	if event_name.is_empty() or not _listeners.has(event_name):
		return
	var callbacks := (_listeners[event_name] as Array[Callable]).duplicate()
	for callback in callbacks:
		if callback.is_valid():
			callback.call(payload)

