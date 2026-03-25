extends RefCounted
class_name Utils


static func load_scene_root_property(scene: PackedScene, prop_name: StringName) -> Variant:
	var scene_state := scene.get_state()
	var prop_count := scene_state.get_node_property_count(0)
	for i in range(prop_count):
		if scene_state.get_node_property_name(0, i) == prop_name:
			return int(scene_state.get_node_property_value(0, i))
	return null
