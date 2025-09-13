class_name Block
extends Node2D

var block_size: Vector2i = Vector2i(100, 100)
var noise: Noise = FastNoiseLite.new()
var block_pos: Vector2i
var grid_data: GridData
var tile_map_layer: TileMapLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# $Sprite2D.visible = Globals.game_controller.debug_config.get("hint_block", false)
	pass

func generate():
	# print("block generate")
	self.grid_data = GridData.new(block_size)
	for in_y in range(block_size.y):
		for in_x in range(block_size.x):
			var x := block_pos.x * block_size.x + in_x
			var y := block_pos.y * block_size.y + in_y
			var height := noise.get_noise_2d(x, y)
			var terrain_type := Globals.Terrain.Dirt
			if height > 0.1:
				terrain_type = Globals.Terrain.Grass
			if height < 0:
				terrain_type = Globals.Terrain.Water
			self.grid_data.set_terrain_type(Vector2i(in_x, in_y), terrain_type)

	# $Sprite2D.scale.x = block_size.x * 32.0 / 128.0
	# $Sprite2D.scale.y = block_size.y * 32.0 / 128.0
	
	
func _enter_tree() -> void:
	fill_tile_map_layer()


func _exit_tree() -> void:
	clean_tile_map_layer()


func clean_tile_map_layer() -> void:
	for in_y in range(block_size.y):
		for in_x in range(block_size.x):
			var x := block_pos.x * block_size.x + in_x
			var y := block_pos.y * block_size.y + in_y
			self.tile_map_layer.erase_cell(Vector2i(x, y))

func fill_tile_map_layer() -> void:
	if self.tile_map_layer == null:
		push_error("tile_map_layer is null", self.name)
		return
	for in_y in range(block_size.y):
		for in_x in range(block_size.x):
			var x := block_pos.x * block_size.x + in_x
			var y := block_pos.y * block_size.y + in_y
			var terrain_type := self.grid_data.get_terrain_type(Vector2i(in_x, in_y))
			if terrain_type == Globals.Terrain.Dirt:
				self.tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
				pass
			elif terrain_type == Globals.Terrain.Grass:
				self.tile_map_layer.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
				pass
			elif terrain_type == Globals.Terrain.Water:
				self.tile_map_layer.set_cell(Vector2i(x, y), 2, Vector2i(0, 0))
				pass
