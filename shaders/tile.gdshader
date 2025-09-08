shader_type canvas_item;

uniform sampler2D noise: filter_nearest, repeat_enable;
varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 sample_pos = world_position * 0.01 + vec2(-TIME, -TIME) * 0.1;
	vec4 noise_overlay = texture(noise, sample_pos);
	COLOR.rgb += 0.1 * noise_overlay.rgb;
}
