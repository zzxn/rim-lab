extends CharacterBody2D


@export var speed: float = 2.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSilhouetteSprite

var direction = "up" # up down


var eight_directions = {
	Vector2(0, -1): "up",
	Vector2(0, 1): "down",
	Vector2(-1, 0): "left",
	Vector2(1, 0): "right",
	Vector2(-1, -1).normalized(): "up-left",
	Vector2(-1, 1).normalized(): "down-left",
	Vector2(1, -1).normalized(): "up-right",
	Vector2(1, 1).normalized(): "down-right",
}

var walk_cool_down := 0.0

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed * Globals.M
		
		var max_dist = 0.0
		for vec in eight_directions:
			var dist = vec.dot(input_dir)
			if dist > 0 and dist > max_dist:
				max_dist = dist
				direction = eight_directions[vec]
				
		
		match direction:
			"up":
				animated_sprite.play("run-back")
				animated_sprite.flip_h = false
			"up-left":
				animated_sprite.play("run-back-side")
				animated_sprite.flip_h = false
			"up-right":
				animated_sprite.play("run-back-side")
				animated_sprite.flip_h = true
			"down":
				animated_sprite.play("run-front")
				animated_sprite.flip_h = false
			"down-left":
				animated_sprite.play("run-front-side")
				animated_sprite.flip_h = false
			"down-right":
				animated_sprite.play("run-front-side")
				animated_sprite.flip_h = true
			"left":
				animated_sprite.play("run-side")
				animated_sprite.flip_h = false
			"right":
				animated_sprite.play("run-side")
				animated_sprite.flip_h = true
			
		move_and_slide()
		if walk_cool_down <= 0:
			$WalkAudioPlayer.play()
			walk_cool_down = 0.36
		else:
			walk_cool_down = max(0, walk_cool_down - delta)
	else:
		match direction:
			"up":
				animated_sprite.play("idle-back")
				animated_sprite.flip_h = false
			"up-left":
				animated_sprite.play("idle-back-side")
				animated_sprite.flip_h = false
			"up-right":
				animated_sprite.play("idle-back-side")
				animated_sprite.flip_h = true
			"down":
				animated_sprite.play("idle-front")
				animated_sprite.flip_h = false
			"down-left":
				animated_sprite.play("idle-front-side")
				animated_sprite.flip_h = false
			"down-right":
				animated_sprite.play("idle-front-side")
				animated_sprite.flip_h = true
			"left":
				animated_sprite.play("idle-side")
				animated_sprite.flip_h = false
			"right":
				animated_sprite.play("idle-side")
				animated_sprite.flip_h = true
	
	if position.x > Globals.MAX_PLAYER_POS:
		position.x = Globals.MAX_PLAYER_POS
	if position.y > Globals.MAX_PLAYER_POS:
		position.y = Globals.MAX_PLAYER_POS

	EventBus.player_position_change.emit(position/32.0)
