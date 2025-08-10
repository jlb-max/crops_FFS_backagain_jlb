shader_type canvas_item;
render_mode unshaded;

// ---------- PARAMÈTRES ----------
uniform float growth       : hint_range(0.0, 1.0) = 0.0;
uniform float fill_amount  : hint_range(0.0, 1.0) = 0.0;
uniform vec4  water_color  : source_color = vec4(0.55, 0.85, 1.0, 0.65);
uniform vec4  rim_color    : source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform float rim_width    : hint_range(0.0, 1.0) = 0.8;
uniform float specular_shine : hint_range(0.0, 128.0) = 64.0;

uniform float flow_speed   : hint_range(0.0,2.0) = 0.8;   // Vitesse des remous
uniform float wave_freq    : hint_range(1.0,20.0) = 10.0; // Fréquence
uniform float wave_amp     : hint_range(0.0,0.1) = 0.025; // Amplitude

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// ----------------- BASE GÉOMÉTRIE -----------------
	vec2 centered_uv = UV * 2.0 - 1.0;
	float dist_from_center = length(centered_uv);
	if (dist_from_center > 1.0) discard;               // cercle parfait

	// ----------------- APPARITION / DISPARITION ---------------
	float growth_mask = smoothstep(0.0, 0.12,
				1.0 - dist_from_center - (1.0 - growth));
	if (growth_mask < 0.01) discard;

	// ----------------- ILLUSION 3D -----------------
	vec3 normal = vec3(centered_uv.x, -centered_uv.y,
		sqrt(max(0.0, 1.0 - dist_from_center * dist_from_center)));
	vec3 view_dir = vec3(0.0, 0.0, 1.0);
	vec3 light_dir = normalize(vec3(0.7, 0.8, 0.6));

	float rim = pow(1.0 - dot(normal, view_dir), 2.0) * rim_width;
	rim = smoothstep(0.0, 1.0, rim);

	vec3 reflect_dir = reflect(-light_dir, normal);
	float spec = pow(max(0.0, dot(view_dir, reflect_dir)), specular_shine);

	// ----------------- ONDULATIONS INTERNE -------------
	// Décale l’UV verticalement avec un sin TIME‑dépendant
	float wave = sin(centered_uv.x * wave_freq + TIME * flow_speed)
			   * wave_amp * (1.0 - dist_from_center);
	vec2 flow_uv = centered_uv;
	flow_uv.y += wave;     // remous internes

	// ----------------- MASQUE DE REMPLISSAGE ----------
	float fill_line = (1.0 - fill_amount) * 2.0 - 1.0 + wave;
	float water_mask = smoothstep(fill_line, fill_line - 0.1, flow_uv.y);

	// ----------------- DISTORSION DE FOND --------------
	vec2 distortion = normalize(centered_uv) * wave_amp * 2.0
	                  * (1.0 - dist_from_center) * growth;
	vec4 back = texture(SCREEN_TEXTURE, SCREEN_UV - distortion);

	// ----------------- COMPOSITION FINALE --------------
	vec3 col = mix(back.rgb, water_color.rgb,
	               water_color.a * water_mask);

	col += rim * rim_color.rgb * rim_color.a; // bord lumineux
	col += spec;                              // reflet spéculaire

	float alpha = growth_mask * 0.45 + water_mask * 0.25;

	COLOR = vec4(col, alpha);
}
