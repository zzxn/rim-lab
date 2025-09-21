shader_type canvas_item;

uniform sampler2D noise: filter_nearest, repeat_enable;
varying vec2 world_position;
uniform vec2 active_world_start;
uniform vec2 active_world_end;

uniform sampler2D terrain_type_data: filter_nearest;
varying vec2 terrain_texture_coords;

uniform sampler2DArray terrain_textures: filter_nearest, repeat_enable;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	terrain_texture_coords = (world_position - active_world_start) / (active_world_end - active_world_start);
}
 
void fragment() {
	if (world_position.x >= active_world_start.x && world_position.x < active_world_end.x && world_position.y >= active_world_start.y && world_position.y < active_world_end.y) {		
		int bend_type = 1;
		vec2 distort = vec2(0.0);
		switch (bend_type) {
			case 1: // brush
				distort += vec2(random(round( fract(world_position / 320.0) * 320.0 ))) - 0.5;
				break;
			case 2: // hand-draw
				distort +=  (texture(noise, world_position * 0.001).rg - 0.5);
				break;
			case 3: // natural
				distort += (texture(noise, world_position * 0.005 + vec2(1.0, 2.0)).rg - 0.5) * 0.5;
				break;
		}
		
		float terrain_type = texture(terrain_type_data, terrain_texture_coords + distort * 32.0 / (active_world_end - active_world_start)).r * 10.0;
		vec4 distort_color = texture(terrain_textures, vec3(fract(world_position / 32.0), terrain_type));
		
		COLOR = distort_color;
		
		// water distort
		//if (abs(terrain_type - 3.0) < 0.1) {
			//float terrain_type = texture(terrain_type_data, terrain_texture_coords + distort * 32.0 * ((sin(TIME * 0.5) + 2.0) * 0.2) / (active_world_end - active_world_start)).r * 10.0;
			//// vec2 terrain_sample_coords = world_position + (texture(noise, world_position * 0.005 + sin(vec2(1.0, 2.0)) * fract(TIME * 0.01)).rg * 10.0 - 0.5) * 10.0;
			//COLOR = texture(terrain_textures, vec3(fract(terrain_texture_coords / 32.0), terrain_type));
			//
			////if (abs(terrain_type - 3.0) < 0.1) {
				////vec2 sample_pos = world_position * 0.01 + vec2(-TIME, -TIME) * 0.1;
				////vec4 noise_overlay = texture(noise, sample_pos);
				////COLOR.rgb += 0.1 * noise_overlay.rgb;
			////}
		//}
		
		// COLOR.g *= 1.1;
	}
}
