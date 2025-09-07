@tool
extends Node

var generate: bool
var clear: bool


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if generate:
		generate = false
		Globals.game_controller.generate_blocks(delta)
