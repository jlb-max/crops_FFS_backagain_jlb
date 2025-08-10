shader_type canvas_item;
render_mode unshaded;

/* -------- capture d’écran ------------------------------------------- */
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

/* -------- paramètres de l'onde -------------------------------------- */
uniform float radius_px   = 64.0;   // rayon du disque (px)
uniform float amplitude   = 8.0;    // déplacement max (px)
uniform float wavelength  = 40.0;   // distance entre crêtes (px)
uniform float speed       = 1.5;    // vagues / seconde
uniform float strength    = 1.0;    // multiplicateur global 0-1

/* -------- paramètres de l'effet d'eau ------------------------------- */
// Couleur et intensité de la teinte appliquée sur les vagues
uniform vec4  tint_color : source_color = vec4(0.8, 0.9, 1.0, 0.15); 
// Augmente la luminosité des crêtes de vagues
uniform float brightness_boost = 0.1; 

/* -------------------------------------------------------------------- */
void fragment() {
	vec2 uv_local = UV * 2.0 - 1.0;
	float dist_rel = length(uv_local);

	// Si on est en dehors du cercle, on ne dessine rien du tout.
	if (dist_rel > 1.0) {
		discard;
	}
	
	// Tout le code suivant ne s'exécute que si on est DANS le cercle.
	float dist_px = dist_rel * radius_px;

	// Calcul des ondes
	float phase1 = (dist_px / wavelength - TIME * speed) * 6.283185;
	float phase2 = (dist_px / (wavelength * 0.7) + TIME * speed * 1.8) * 6.283185;
	float wave = (sin(phase1) + sin(phase2)) * 0.5;

	// Calcul du déplacement
	float falloff = pow(1.0 - dist_rel, 2.0);
	float offset_px = wave * amplitude * falloff * strength;
	vec2 dir = normalize(uv_local);
	vec2 sample_uv = SCREEN_UV - dir * offset_px * SCREEN_PIXEL_SIZE;
	
	// On récupère la couleur déformée
	vec4 original_color = texture(SCREEN_TEXTURE, sample_uv);
	
	// Calcul de la teinte
	float wave_for_color = wave * falloff * strength;
	vec3 final_color = mix(original_color.rgb, tint_color.rgb, abs(wave_for_color) * tint_color.a);
	final_color += wave_for_color * brightness_boost;

	COLOR = vec4(final_color, original_color.a);
}