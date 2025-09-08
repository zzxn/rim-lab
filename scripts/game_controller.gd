class_name GameController extends Node

@export
var block_size: Vector2i = Vector2i(8, 8)

@export
var noise: Noise = FastNoiseLite.new()

@export
var player: Node2D

@onready var blocks_parent: Node = $Blocks

var block_scene: PackedScene = preload("res://scenes/block.tscn")
var generate_thread: Thread

var last_player_pos: Vector2
var curr_block_pos_list = []
var curr_block_dict: Dictionary = {}
var generate_task_dict: Dictionary = {} # key: block_pos, value: task_id

const LOAD_DISTANCE = 4

const BLOCK_ENTER_SCENE_TIME_GAP = 0.025
var block_enter_timeout = 0.0

var block_enter_scene_queue = []

var debug_config: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("main ready")
	Engine.max_fps = 240
	Globals.game_controller = self
	EventBus.debug_config_change.connect(_on_debug_info_debug_config_change)


func _physics_process(delta: float) -> void:
	generate_blocks(delta)

func generate_blocks(delta: float):
	var player_position := player.position if player else Vector2.ZERO
	var curr_block_pos = global_to_block_pos(player_position)
	var required_block_pos_list := []
	for dy in range(-LOAD_DISTANCE, LOAD_DISTANCE+1):
		for dx in range(-LOAD_DISTANCE, LOAD_DISTANCE+1):
			required_block_pos_list.append(Vector2i(curr_block_pos.x + dx, curr_block_pos.y + dy))

	# load blocks
	for block_pos in required_block_pos_list:
		if block_pos not in curr_block_dict and block_pos not in generate_task_dict:
			var task_id := WorkerThreadPool.add_task(generate_block.bind(block_pos))
			generate_task_dict[block_pos] = task_id

	# unload blocks
	for block in curr_block_dict.values():
		if abs(block.block_pos.x - curr_block_pos.x) >= (LOAD_DISTANCE + 2) or abs(block.block_pos.y - curr_block_pos.y) >= (LOAD_DISTANCE + 2):
			remove_block(block)
	
	# add blocks to scenes
	block_enter_timeout = max(block_enter_timeout - delta, 0)
	if block_enter_timeout <= 0 and block_enter_scene_queue:
		block_enter_timeout += BLOCK_ENTER_SCENE_TIME_GAP
		var block = block_enter_scene_queue.pop_front()
		if block.block_pos in curr_block_dict:
			push_warning("block exit!", str(block.block_pos))
		else:
			print("add_child(block)", str(block.block_pos))
			curr_block_dict[block.block_pos] = block
			blocks_parent.add_child(block)
			generate_task_dict.erase(block.block_pos)


func generate_block(pos: Vector2i):
	#print("generate_block", str(pos))
	var block: Block = block_scene.instantiate()
	block.noise = noise
	block.block_size = block_size
	block.block_pos = pos
	block.position = Vector2(pos.x * block_size.x * 32, pos.y * block_size.y * 32)
	block.name = "Block " + str(pos)
	block.generate()
	call_deferred("queue_add_block", block)


func global_to_block_pos(global_pos: Vector2) -> Vector2i:
	return Vector2i(floori(global_pos.x / 32 / block_size.x), floori(global_pos.y / 32 / block_size.y))
	

func queue_add_block(block: Block):
	print("queue_add_block", str(block.block_pos))
	block_enter_scene_queue.append(block)


func remove_block(block: Block):
	print("remove_block", str(block.block_pos))
	curr_block_dict.erase(block.block_pos)
	block.queue_free()


func _on_debug_info_debug_config_change(key: String, value) -> void:
	print("_on_debug_info_debug_config_change(", key, ", ", value, ")")
	self.debug_config[key] = value
