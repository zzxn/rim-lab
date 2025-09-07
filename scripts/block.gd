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
	if not reset:
		return
	reset = false
	generate()

func generate():
	# print("block generate")
	self.grid_data = GridData.new(block_size)
	# print(str(block_size))
	self.clear()
	for y in range(block_size.y):
		for x in range(block_size.x):
			var height := noise.get_noise_2d(block_pos.x * block_size.x + x, block_pos.y * block_size.y + y)
			var terrain_type := RimEnum.Terrain.Dirt
			if height > 0.1:
				terrain_type = RimEnum.Terrain.Grass
			if height < 0:
				terrain_type = RimEnum.Terrain.Water
			# print("(%d, %d) height is %f" % [x, y, height])
			self.grid_data.set_terrain_type(Vector2i(x, y), terrain_type)
			if terrain_type == RimEnum.Terrain.Dirt:
				self.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			elif terrain_type == RimEnum.Terrain.Grass:
				self.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
			elif terrain_type == RimEnum.Terrain.Water:
				self.set_cell(Vector2i(x, y), 2, Vector2i(0, 0))

	$Sprite2D.scale.x = block_size.x * 32.0 / 128.0
	$Sprite2D.scale.y = block_size.y * 32.0 / 128.0
