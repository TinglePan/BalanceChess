extends RefCounted
class_name Utils


static func load_scene_root_property(scene: PackedScene, prop_name: StringName) -> Variant:
	var scene_state := scene.get_state()
	var prop_count := scene_state.get_node_property_count(0)
	for i in range(prop_count):
		if scene_state.get_node_property_name(0, i) == prop_name:
			return int(scene_state.get_node_property_value(0, i))
	return null


# Returns zipped pairs in the form [left_item, right_item].
# Pairing stops at the shortest array length.
static func zip(left: Array, right: Array) -> Array:
	var pairs: Array = []
	var pair_count := mini(left.size(), right.size())
	for i in range(pair_count):
		pairs.append([left[i], right[i]])
	return pairs
