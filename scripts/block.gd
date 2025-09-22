class_name Block
extends Node2D

var block_size: Vector2i = Vector2i(100, 100)
var noise: Noise = FastNoiseLite.new()
var humidity_noise: FastNoiseLite = FastNoiseLite.new()
var block_pos: Vector2i
var grid_data: GridData
var tile_map_layer: TileMapLayer

var terrain_data_image: Image
var terrain_data_image_texture: ImageTexture

var world_objects := []

@onready var sprite_2d: Sprite2D = $Sprite2D

var tree_scene: PackedScene = preload("res://scenes/tree.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# $Sprite2D.visible = Globals.game_controller.debug_config.get("hint_block", false)
	pass
	

func _ready() -> void:
	sprite_2d.texture = self.terrain_data_image_texture
	sprite_2d.scale *= 10
	humidity_noise.seed = 2333


func generate():
	# print("block generate")
	self.grid_data = GridData.new(block_size)
	self.terrain_data_image = Image.create(block_size.x, block_size.y, false, Image.FORMAT_RGBA8)
	self.terrain_data_image.fill(Color(0.0, 0.0, 0.0, 1.0))
	
	for in_y in range(block_size.y):
		for in_x in range(block_size.x):
			var has_green := false
			var has_water := false
			
			var x := block_pos.x * block_size.x + in_x
			var y := block_pos.y * block_size.y + in_y
			var height := noise.get_noise_2d(x, y)
			var terrain_type := Globals.Terrain.Dirt
			if height > 0.1:
				terrain_type = Globals.Terrain.Grass
			elif height < 0:
				terrain_type = Globals.Terrain.Water
				has_water = true
			self.grid_data.set_terrain_type(Vector2i(in_x, in_y), terrain_type)

			if terrain_type != Globals.Terrain.Water:
				var humidity := humidity_noise.get_noise_2d(x, y)
				if humidity > 0.3:
					var tree: Node = tree_scene.instantiate()
					tree.position = Vector2(x + randf() * 0.5, y + randf() * 0.5) * 32
					world_objects.append(tree)
					has_green = true

			var data_color := Color(terrain_type * 0.1, terrain_type * 0.1, terrain_type * 0.1, 1.0)
			if has_green:
				data_color.g = 0.5
			if has_water:
				data_color.b = 0.5
			self.terrain_data_image.set_pixel(in_x, in_y, data_color)


	self.terrain_data_image_texture = ImageTexture.create_from_image(self.terrain_data_image)
	# $Sprite2D.scale.x = block_size.x * 32.0 / 128.0
	# $Sprite2D.scale.y = block_size.y * 32.0 / 128.0
	
	
func _enter_tree() -> void:
	fill_tile_map_layer()
	for obj in world_objects:
		Globals.game_controller.get_node("World").add_child(obj)


func _exit_tree() -> void:
	clean_tile_map_layer()
	for obj in world_objects:
		obj.queue_free()


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
			if terrain_type in Globals.TerrainCell:
				self.tile_map_layer.set_cell(Vector2i(x, y), Globals.TerrainCell[terrain_type][0], Globals.TerrainCell[terrain_type][1])
