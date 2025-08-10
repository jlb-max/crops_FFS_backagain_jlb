shader_type canvas_item;

void fragment() {
	// On calcule la distance de chaque pixel par rapport au centre de la texture.
	float dist_from_center = distance(UV, vec2(0.5));
	
	// On utilise smoothstep pour créer un masque circulaire avec un bord adouci.
	// 1.0 au centre, 0.0 sur les bords.
	float alpha_mask = 1.0 - smoothstep(0.2, 0.4, dist_from_center);
	
	// La couleur finale est la couleur de la texture de votre lumière...
	COLOR = texture(TEXTURE, UV);
	// ...mais sa transparence est multipliée par notre masque circulaire.
	COLOR.a *= alpha_mask;
}