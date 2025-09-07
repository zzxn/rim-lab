extends VBoxContainer

@onready var fps_label: Label = $FPSLabel

signal debug_config_change

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: " + str(fps)


func _on_hint_block_check_button_toggled(toggled_on: bool) -> void:
	debug_config_change.emit("hint_block", toggled_on)
