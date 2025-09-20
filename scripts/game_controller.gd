class_name GameController extends Node

@export
var block_size: Vector2i = Vector2i(8, 8)

@export
var noise: Noise = FastNoiseLite.new()

@export
var player: Node2D

@onready var blocks_parent: Node = $Blocks
@onready var terrain_tile_map_layer: TileMapLayer = $TerrainTileMapLayer

var block_scene: PackedScene = preload("res://scenes/block.tscn")

var last_block_pos: Vector2i

var curr_block_pos_list = []
var curr_block_dict: Dictionary = {}
var generate_task_dict: Dictionary = {} # key: block_pos, value: task_id

const LOAD_DISTANCE = 4

const ACTIVE_DISTANCE = min(LOAD_DISTANCE, 2)
var active_world_start: Vector2
var active_world_end: Vector2

const MAX_PLAYER_POS_LIMIT = 8000 * Globals.M

const BLOCK_ENTER_SCENE_TIME_GAP = 0.01
var block_enter_timeout = 0.0

var block_enter_scene_queue = []

var debug_config: Dictionary

var visible_terrian_image: Image
@onready var visible_terrian_sprite: Sprite2D = $HUD/DebugInfo/VisibleTerrianSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# print_debug("main ready")
	Engine.max_fps = 240
	Globals.game_controller = self
	EventBus.debug_config_change.connect(_on_debug_info_debug_config_change)
	self.visible_terrian_image = Image.create_empty((ACTIVE_DISTANCE * 2 + 1) * block_size.x, (ACTIVE_DISTANCE * 2 + 1) * block_size.y, false, Image.FORMAT_RGBA8)
	print("size ", str((ACTIVE_DISTANCE * 2 + 1) * block_size.x))
	
	var texture_2d_array := Texture2DArray.new()
	texture_2d_array.create_from_images([
		Image.load_from_file("res://sprites/dirt.png"),
		Image.load_from_file("res://sprites/dirt.png"),
		Image.load_from_file("res://sprites/grass.png"),
		Image.load_from_file("res://sprites/water.png"),
	])
	var mat := terrain_tile_map_layer.material as ShaderMaterial
	mat.set_shader_parameter("terrain_textures", texture_2d_array)
	


func _physics_process(delta: float) -> void:
	load_unload_blocks(delta)
	process_block_enter_queue(delta)
	process_terrain_texture(delta)


func load_unload_blocks(delta: float):
	var player_position := player.position if player else Vector2.ZERO
	var curr_block_pos = global_to_block_pos(player_position)
	if last_block_pos and curr_block_pos == last_block_pos:
		return
	last_block_pos = curr_block_pos
	EventBus.current_block_position.emit(curr_block_pos)

	var required_block_pos_list := []
	for dy in range(-LOAD_DISTANCE, LOAD_DISTANCE+1):
		for dx in range(-LOAD_DISTANCE, LOAD_DISTANCE+1):
			required_block_pos_list.append(Vector2i(curr_block_pos.x + dx, curr_block_pos.y + dy))
	
	required_block_pos_list.sort_custom(func (a, b): return a.distance_squared_to(curr_block_pos) <  b.distance_squared_to(curr_block_pos))

	# load blocks
	for block_pos in required_block_pos_list:
		if block_pos not in curr_block_dict and block_pos not in generate_task_dict:
			print_debug("add_generate_block_task", str(block_pos))
			var task_id := WorkerThreadPool.add_task(generate_block.bind(block_pos))
			generate_task_dict[block_pos] = task_id

	# unload blocks
	for block in curr_block_dict.values():
		if abs(block.block_pos.x - curr_block_pos.x) >= (LOAD_DISTANCE + 2) or abs(block.block_pos.y - curr_block_pos.y) >= (LOAD_DISTANCE + 2):
			remove_block(block)


func process_block_enter_queue(delta: float):
	# add blocks to scenes
	block_enter_timeout = max(block_enter_timeout - delta, 0)
	if block_enter_timeout <= 0 and block_enter_scene_queue:
		block_enter_timeout += BLOCK_ENTER_SCENE_TIME_GAP
		var block = block_enter_scene_queue.pop_front()
		if block.block_pos in curr_block_dict:
			push_warning("block already generated...", str(block.block_pos))
		else:
			print_debug("add_child(block)", str(block.block_pos))
			curr_block_dict[block.block_pos] = block
			blocks_parent.add_child(block)
			generate_task_dict.erase(block.block_pos)


func process_terrain_texture(delta: float):
	visible_terrian_image.fill(Color(0, 0, 0, 1))
	for dy in range(-ACTIVE_DISTANCE, ACTIVE_DISTANCE+1):
		for dx in range(-ACTIVE_DISTANCE, ACTIVE_DISTANCE+1):
			var block_pos := Vector2i(last_block_pos.x + dx, last_block_pos.y + dy)
			if block_pos in curr_block_dict:
				var block: Block = curr_block_dict[block_pos]
				visible_terrian_image.blend_rect(block.terrain_data_image, Rect2i(0, 0, block_size.x, block_size.y), Vector2i((dx + ACTIVE_DISTANCE) * block_size.x, (dy + ACTIVE_DISTANCE) * block_size.y))
	var visible_terrian_image_texture := ImageTexture.create_from_image(visible_terrian_image)
	visible_terrian_sprite.texture = visible_terrian_image_texture
	var mat := terrain_tile_map_layer.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("terrain_type_data", visible_terrian_image_texture)
		
	active_world_start = Vector2(last_block_pos.x - ACTIVE_DISTANCE, last_block_pos.y - ACTIVE_DISTANCE) * block_size.x * 32
	active_world_end = Vector2(last_block_pos.x + ACTIVE_DISTANCE + 1, last_block_pos.y + ACTIVE_DISTANCE + 1) * block_size.y * 32
	# print("active_world_start", str(active_world_start))
	# print("active_world_end", str(active_world_end))
	mat.set_shader_parameter("active_world_start", active_world_start)
	mat.set_shader_parameter("active_world_end", active_world_end)


func generate_block(pos: Vector2i):
	# print("generate_block", str(pos), " ======= ", str(terrain_tile_map_layer))
	var block: Block = block_scene.instantiate()
	block.noise = noise
	block.block_size = block_size
	block.block_pos = pos
	block.position = Vector2(pos.x * block_size.x * 32, pos.y * block_size.y * 32)
	block.name = "Block " + str(pos)
	block.tile_map_layer = terrain_tile_map_layer
	block.generate()
	call_deferred("queue_add_block", block)


func global_to_block_pos(global_pos: Vector2) -> Vector2i:
	return Vector2i(floori(global_pos.x / 32.0 / block_size.x), floori(global_pos.y / 32.0 / block_size.y))
	

func queue_add_block(block: Block):
	print_debug("queue_add_block", str(block.block_pos))
	block_enter_scene_queue.append(block)


func remove_block(block: Block):
	print_debug("remove_block", str(block.block_pos))
	curr_block_dict.erase(block.block_pos)
	block.queue_free()


func _on_debug_info_debug_config_change(key: String, value) -> void:
	# print_debug("_on_debug_info_debug_config_change(", key, ", ", value, ")")
	self.debug_config[key] = value
