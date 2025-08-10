# res://scripts/globals/VisualEffectsManager.gd (Vérifie que ce code est bien le tien)
extends Node

var gravity_sources: Array = []
var heat_sources: Array = []
var effect_material: ShaderMaterial

func _ready():
	pass

func set_active_material(mat: ShaderMaterial):
	effect_material = mat

# --- VÉRIFIE BIEN QUE CES FONCTIONS SONT PRÉSENTES ET CORRECTEMENT NOMMÉES ---
func register_gravity_source(source: Node2D):
	if not gravity_sources.has(source):
		gravity_sources.append(source)

func unregister_gravity_source(source: Node2D):
	gravity_sources.erase(source)
# --------------------------------------------------------------------
func _process(delta: float) -> void:
	if not effect_material:
		return
	update_gravity_uniforms()

func update_gravity_uniforms() -> void:
	var sources_data: Array = []
	for source in gravity_sources:
		if is_instance_valid(source):
			# --- IL N'Y A PLUS AUCUN CALCUL DE POSITION ICI ---
			# On lit simplement la valeur stockée, qui est garantie d'être correcte et fixe.
			var screen_pos: Vector2 = source.fixed_screen_position
			
			var radius: float = source.plant_data.gravity_effect.gravity_radius
			var strength: float = source.get_current_gravity_strength()
			
			sources_data.append(Vector4(screen_pos.x, screen_pos.y, radius, strength))
	
	effect_material.set_shader_parameter("gravity_sources", sources_data)
	effect_material.set_shader_parameter("gravity_source_count", sources_data.size())
