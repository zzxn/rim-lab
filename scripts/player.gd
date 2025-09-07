extends CharacterBody2D


@export var speed := 5500
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed * delta
		animated_sprite.play("run")
		move_and_slide()
	else:
		animated_sprite.play("idle")
		
