extends Node

@export
var block_size: Vector2i = Vector2i(5, 5)

@export
var noise: Noise = FastNoiseLite.new()

@export
var player: Node2D

var block_scene: PackedScene = preload("res://scenes/block.tscn")
var generate_thread: Thread

var last_player_pos: Vector2
var curr_block_pos_list = []
var curr_block_dict: Dictionary = {}
var generate_task_dict: Dictionary = {} # key: block_pos, value: task_id

const LOAD_DISTANCE = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("main ready")
	Engine.max_fps = 240

func _physics_process(delta: float) -> void:
	generate()
	

func generate():
	if not player:
		return
	var curr_block_pos = player_pos_to_block_pos(player.position)
	var required_block_pos_list := []
	for dy in range(-LOAD_DISTANCE, LOAD_DISTANCE+1):
		for dx in range(-LOAD_DISTANCE, LOAD_DISTANCE+1):
			required_block_pos_list.append(Vector2i(curr_block_pos.x + dx, curr_block_pos.y + dy))

	# load blocks
	for block_pos in required_block_pos_list:
		if block_pos not in curr_block_dict and block_pos not in generate_task_dict:
			var task_id := WorkerThreadPool.add_task(generate_block.bind(block_pos))
			generate_task_dict[block_pos] = task_id
		#if block_pos not in curr_block_dict and block_pos not in generate_task_dict:
		#	generate_block(block_pos)
	# unload blocks
	for block in curr_block_dict.values():
		if abs(block.block_pos.x - curr_block_pos.x) >= (LOAD_DISTANCE + 2) or abs(block.block_pos.y - curr_block_pos.y) >= (LOAD_DISTANCE + 2):
			remove_block(block)


func generate_block(pos: Vector2i):
	#print("generate_block", str(pos))
	var block: Block = block_scene.instantiate()
	block.noise = noise
	block.block_size = block_size
	block.block_pos = pos
	block.position = Vector2(pos.x * block_size.x * 32, pos.y * block_size.y * 32)
	block.generate()
	# OS.delay_msec(randi() % 100)
	call_deferred("add_block", block)


func player_pos_to_block_pos(player_pos: Vector2) -> Vector2i:
	return Vector2i(floori(player_pos.x / 32 / block_size.x), floori(player_pos.y / 32 / block_size.y))
	

func add_block(block: Block):
	#print("add_block", str(block.block_pos))
	if block.block_pos in curr_block_dict:
		push_warning("block exit!", str(block.block_pos))
		return
	curr_block_dict[block.block_pos] = block
	add_child(block)
	generate_task_dict.erase(block.block_pos)


func remove_block(block: Block):
	print("remove_block", str(block.block_pos))
	curr_block_dict.erase(block.block_pos)
	block.queue_free()
