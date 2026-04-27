extends RefCounted
class_name MyLogger


enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
}


static func print_formatted_log(message: Variant, tag: String = "", level: LogLevel = LogLevel.INFO, context: Variant = null) -> void:
	print(format_log_message(message, tag, level, context))


static func format_log_message(message: Variant, tag: String = "", level: LogLevel = LogLevel.INFO, context: Variant = null) -> String:
	var parts: PackedStringArray = []
	parts.append("[%s]" % Time.get_datetime_string_from_system())

	var level_label := _get_log_level_label(level)
	if not level_label.is_empty():
		parts.append("[%s]" % level_label)

	var normalized_tag := tag.strip_edges()
	if not normalized_tag.is_empty():
		parts.append("[%s]" % normalized_tag)

	parts.append(str(message))

	if context != null:
		parts.append("| %s" % var_to_str(context))

	return " ".join(parts)


static func _get_log_level_label(level: LogLevel) -> String:
	match level:
		LogLevel.DEBUG:
			return "DEBUG"
		LogLevel.INFO:
			return "INFO"
		LogLevel.WARNING:
			return "WARNING"
		LogLevel.ERROR:
			return "ERROR"
		_:
			return "UNKNOWN"


