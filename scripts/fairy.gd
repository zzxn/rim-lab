extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("!!!!!!!!!!!!!!!!!!!!!!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Globals.game_controller.player:
		var move_dir := Globals.game_controller.player.position - position
		if move_dir.length() > 2 * Globals.M and move_dir.length() < 10 * Globals.M:
			velocity = move_dir.normalized() * 1.5 * Globals.M
			move_and_slide()
