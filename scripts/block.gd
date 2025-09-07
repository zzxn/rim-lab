@tool
class_name Block
extends TileMapLayer

@export
var block_size: Vector2i = Vector2i(100, 100)

@export
var noise: Noise = FastNoiseLite.new()

@export
var block_pos: Vector2i

@export
var reset: bool

var grid_data: GridData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if reset:
			reset = false
			generate()
	else:
		$Sprite2D.visible = Globals.game_controller.debug_config.get("hint_block", false)

func generate():
	# print("block generate")
	self.grid_data = GridData.new(block_size)
	# print(str(block_size))
	self.clear()
	for y in range(block_size.y):
		for x in range(block_size.x):
			var height := noise.get_noise_2d(block_pos.x * block_size.x + x, block_pos.y * block_size.y + y)
			var terrain_type := Globals.Terrain.Dirt
			if height > 0.1:
				terrain_type = Globals.Terrain.Grass
			if height < 0:
				terrain_type = Globals.Terrain.Water
			# print("(%d, %d) height is %f" % [x, y, height])
			self.grid_data.set_terrain_type(Vector2i(x, y), terrain_type)
			if terrain_type == Globals.Terrain.Dirt:
				self.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			elif terrain_type == Globals.Terrain.Grass:
				self.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
			elif terrain_type == Globals.Terrain.Water:
				self.set_cell(Vector2i(x, y), 2, Vector2i(0, 0))

	$Sprite2D.scale.x = block_size.x * 32.0 / 128.0
	$Sprite2D.scale.y = block_size.y * 32.0 / 128.0
