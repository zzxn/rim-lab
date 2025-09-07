extends Camera2D


var zoom_level = 4.0
var zoom_step = 1.05
var zoom_max = 8.0
var zoom_min = 0.5

func _ready() -> void:
	self.zoom = Vector2(zoom_level, zoom_level)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom_level = min(zoom_level * 1.05, zoom_max)
	elif event.is_action_pressed("zoom_out"):
		zoom_level = max(zoom_level / 1.05, zoom_min)

func _process(delta: float) -> void:
	if self.zoom.x != zoom_level:
		self.zoom = lerp(self.zoom, Vector2(zoom_level, zoom_level), 10 * delta)
