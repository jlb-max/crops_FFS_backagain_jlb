// Shader pour adoucir les tuiles en cercle
shader_type canvas_item;

// Ces variables apparaîtront dans l'inspecteur pour un réglage facile
uniform float radius : hint_range(0.0, 0.5) = 0.5; // Le rayon du cercle. 0.5 remplit la tuile.
uniform float softness : hint_range(0.0, 0.5) = 0.2; // La douceur du dégradé sur les bords.

void fragment() {
	// On récupère la couleur de votre texture de base (le carré semi-transparent)
	vec4 texture_color = texture(TEXTURE, UV);

	// UV est la coordonnée du pixel à l'intérieur de la tuile (de 0.0 à 1.0)
	// On calcule la distance de ce pixel par rapport au centre de la tuile (0.5, 0.5)
	float dist_from_center = distance(UV, vec2(0.5));

	// On utilise "smoothstep" pour créer un cercle adouci.
	// Il passera de 1.0 (visible) à 0.0 (transparent) sur le bord du cercle.
	float circle_alpha = 1.0 - smoothstep(radius - softness, radius, dist_from_center);

	// La couleur finale du pixel est la couleur de la texture,
	// mais son alpha (transparence) est multiplié par la valeur du cercle.
	COLOR = texture_color;
	COLOR.a *= circle_alpha;
}