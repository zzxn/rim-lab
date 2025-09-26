shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;

uniform vec4 silhouette_color = vec4(1.0, 0.0, 0.0, 0.5);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 sprite_color = texture(TEXTURE, UV);
	if (all(lessThan(abs(sprite_color - screen_color), vec4(0.01)))) {
		COLOR = sprite_color;
	} else {
		COLOR = vec4(silhouette_color.rgb, silhouette_color.a * sprite_color.a);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
