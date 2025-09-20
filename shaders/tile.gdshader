shader_type canvas_item;

uniform sampler2D noise: filter_nearest, repeat_enable;
varying vec2 world_position;
uniform vec2 active_world_start;
uniform vec2 active_world_end;

uniform sampler2D terrain_type_data: filter_nearest;
varying vec2 terrain_texture_coords;

uniform sampler2DArray terrain_textures: filter_nearest;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	terrain_texture_coords = (world_position - active_world_start) / (active_world_end - active_world_start);
}
 
void fragment() {
	vec2 sample_pos = world_position * 0.01 + vec2(-TIME, -TIME) * 0.1;
	vec4 noise_overlay = texture(noise, sample_pos);
	COLOR.rgb += 0.1 * noise_overlay.rgb;
	vec2 uv = UV;
	
	if (world_position.x >= active_world_start.x && world_position.x < active_world_end.x && world_position.y >= active_world_start.y && world_position.y < active_world_end.y) {
		// vec2 distort_coords = terrain_texture_coords + 0.02 * random(round(world_position));
		
		int bend_type = 3;
		vec2 distort = vec2(0.0);
		switch (bend_type) {
			case 1: // brush
				distort += vec2(random(round(world_position)));
				break;
			case 2: // hand-draw
				distort +=  (texture(noise, world_position * 0.001).rg - 0.5);
				break;
			case 3: // natural
				distort += (texture(noise, world_position * 0.005 + vec2(1.0, 2.0)).rg - 0.5) * 0.5;
				break;
		}
		
		float terrain_type = texture(terrain_type_data, terrain_texture_coords + distort * 32.0 / (active_world_end - active_world_start)).r * 10.0;
		COLOR = texture(terrain_textures, vec3(fract(world_position * 0.005), terrain_type));
		// COLOR 
		// COLOR.rgb = texture(terrain_type_data, terrain_texture_coords).rgb;
	}
}
