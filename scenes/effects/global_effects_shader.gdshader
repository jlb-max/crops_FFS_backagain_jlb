// res://shaders/global_effects_shader.gdshader
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ---- UNIFORMS GLOBAUX ----
// On définit une taille maximale pour le tableau.
// Elle doit être assez grande pour tes besoins, mais pas trop pour la performance.
const int MAX_SOURCES = 32;


// ---- EFFETS DE GRAVITÉ ----
uniform int gravity_source_count;
// Chaque vec4 contient : .x=pos_x, .y=pos_y, .z=radius_px, .w=strength
uniform vec4 gravity_sources[MAX_SOURCES];

// Paramètres que l'on suppose constants pour l'instant (à passer en uniform si besoin)
uniform float amplitude = 8.0;
uniform float wavelength = 40.0;
uniform float speed = 1.5;


void fragment() {
	vec2 total_offset = vec2(0.0);
	
	for (int i = 0; i < gravity_source_count; i++) {
		vec4 source = gravity_sources[i];
		vec2 source_screen_pos = source.xy; // On utilise directement la position écran reçue
		float radius_px = source.z;
		float strength = source.w;
		
		float dist_px = distance(FRAGCOORD.xy, source_screen_pos);
		
		if (dist_px < radius_px) {
			float dist_rel = dist_px / radius_px;
			float phase = (dist_px / wavelength - TIME * speed) * 6.283185;
			float wave = sin(phase);
			float falloff = pow(1.0 - dist_rel, 2.0);
			vec2 dir = normalize(source_screen_pos - FRAGCOORD.xy);
			vec2 current_offset = dir * wave * amplitude * falloff * strength;
			total_offset += current_offset;
		}
	}

	vec2 sample_uv = SCREEN_UV + total_offset * SCREEN_PIXEL_SIZE;
	vec4 original_color = texture(SCREEN_TEXTURE, sample_uv);
	
	COLOR = original_color;
}