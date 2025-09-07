class_name GridData



var size: Vector2i
var terrain_type_map: Dictionary[Vector2i, Globals.Terrain]


func _init(size: Vector2i):
	self.size = size


func set_terrain_type(pos: Vector2i, terrain_type: Globals.Terrain) -> void:
	terrain_type_map[pos] = terrain_type


func get_terrain_type(pos: Vector2i) -> Globals.Terrain:
	return terrain_type_map.get(pos, Globals.Terrain.Base)
