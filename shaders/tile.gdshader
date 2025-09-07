shader_type canvas_item;

uniform sampler2D noise;

void vertex() {
}

void fragment() {
	vec2 uv = UV;
	vec4 noise_color = texture(noise, uv);
	COLOR *= step(fract(TIME * 0.1), noise_color);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
