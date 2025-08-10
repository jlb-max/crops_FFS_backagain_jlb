shader_type canvas_item;
render_mode unshaded;

/* ------------- Capture d’écran ---------------------------------------- */
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

/* ------------- Paramètres pilotables ---------------------------------- */
uniform float radius_px = 128.0;   // rayon en pixels ( = la moitié du quad )
uniform float strength  = 0.8;    // 0‑1

/* ---------------------------------------------------------------------- */
void fragment()
{
    /* UV locaux du BackBufferCopy : 0‑1 → centre = 0.5 */
    vec2 uv_local = UV * 2.0 - 1.0;        // −1 → 1 (centre = 0)
    float dist    = length(uv_local);

    float radius  = 1.0;                   // car quad = 128 px  →  64 px = 1.0
    vec2 sample_uv = SCREEN_UV;            // par défaut : pas de déformation

    if (dist < radius) {
        float pct = (radius - dist) / radius;       // 1 → 0 du centre au bord
        sample_uv -= uv_local * pct * strength * 0.5;
    }

    COLOR = texture(SCREEN_TEXTURE, sample_uv);

}
