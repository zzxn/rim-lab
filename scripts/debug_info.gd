extends VBoxContainer

@onready var fps_label: Label = $FPSLabel
@onready var player_position_label: Label = $PlayerPositionLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_position_change.connect(_on_player_position_change)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: " + str(fps)


func _on_hint_block_check_button_toggled(toggled_on: bool) -> void:
	EventBus.debug_config_change.emit("hint_block", toggled_on)


func _on_player_position_change(position: Vector2):
	player_position_label.text = ("Player Position: (%.2f, %.2f)" % [position.x, position.y])
	
	
