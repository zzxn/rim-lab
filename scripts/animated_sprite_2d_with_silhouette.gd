extends AnimatedSprite2D

@onready var silhouette: AnimatedSprite2D = $Silhouette


func _ready():
	copy_props()
	


func _process(_delta: float) -> void:
	copy_props()


func copy_props():
	silhouette.sprite_frames = sprite_frames
	silhouette.offset = offset
	silhouette.flip_h = flip_h
	silhouette.animation = animation
	silhouette.frame = frame
	silhouette.speed_scale = speed_scale
	silhouette.flip_v = flip_v
	silhouette.centered = centered


## Copy the propeties to the silouette sprite
#func _set(property: StringName, value: Variant) -> bool:
	#if not is_instance_valid(silhouette):
		#push_warning("Invalid silhouette sprite")
		#return false
	#
	#match property:
		#"animation":
			#silhouette.animation = value
		#"flip_h":
			#silhouette.flip_h = value
		#"offset":
			#silhouette.offset = value
		#"frame":
			#silhouette.frame = value
		#"sprite_frames":
			#silhouette.sprite_frames = value
		#"speed_scale":
			#silhouette.speed_scale = value
		#"flip_v":
			#silhouette.flip_v = value
		#"centered":
			#silhouette.centered = value
	#return true
