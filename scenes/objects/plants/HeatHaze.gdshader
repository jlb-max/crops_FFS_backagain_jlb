shader_type canvas_item;
render_mode unshaded;

// On garde les mêmes textures d'entrée
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise_texture : source_color, filter_linear_mipmap;

// On ajuste les paramètres pour plus de contrôle
uniform float strength : hint_range(0.0, 0.05) = 0.005;
uniform float speed : hint_range(0.0, 0.5) = 0.1;
// Nouveau paramètre pour contrôler l'ondulation verticale
uniform float turbulence : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	// --- LIGNE MANQUANTE AJOUTÉE ICI ---
	// Crée un repère local où le centre est (0,0) et les bords sont à 1.0
	vec2 uv_local = UV * 2.0 - 1.0;
	// ------------------------------------

	float dist_rel = length(uv_local);

	// Si on est en dehors du cercle d'effet, on ne dessine rien
	if (dist_rel > 1.0) {
		discard;
	}

	// On calcule un "fondu" pour que l'effet soit moins fort sur les bords
    float falloff = 1.0 - dist_rel;

	// On crée deux mouvements de "scroll" différents pour la turbulence
	vec2 uv_scroll_main = UV + vec2(0.0, -TIME * speed); // Mouvement principal vers le haut
	vec2 uv_scroll_turb = UV + vec2(TIME * speed * 0.2, -TIME * speed * 0.8); // Mouvement diagonal plus lent

	// On lit le bruit à deux endroits différents
	float noise1 = texture(noise_texture, uv_scroll_main).r;
	float noise2 = texture(noise_texture, uv_scroll_turb).r;

	// On convertit le bruit de [0,1] à [-1,1] pour avoir une distorsion dans les deux sens
	noise1 = (noise1 - 0.5) * 2.0;
	noise2 = (noise2 - 0.5) * 2.0;

	// On utilise les deux bruits pour créer un vecteur de décalage 2D
	vec2 offset;
	// noise1 contrôle la distorsion horizontale principale
	offset.x = noise1; 
	// noise2 contrôle la distorsion verticale, modulée par notre paramètre "turbulence"
	offset.y = noise2 * turbulence;

	// On applique le décalage final aux coordonnées de l'écran, en tenant compte du fondu
	vec2 screen_uv_distorted = SCREEN_UV - offset * strength * falloff;

	COLOR = texture(SCREEN_TEXTURE, screen_uv_distorted);
}