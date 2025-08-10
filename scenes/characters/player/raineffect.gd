# RainEffect.gd
extends GPUParticles2D

# On récupère le matériau une seule fois
@onready var shader_material: ShaderMaterial = process_material as ShaderMaterial

func _ready() -> void:
	emitting = false
	WeatherManager.weather_changed.connect(on_weather_changed)

func on_weather_changed(new_weather: int) -> void:
	emitting = (new_weather == WeatherManager.Weather.RAINING)
	# On active/désactive le process seulement si nécessaire pour optimiser
	set_process(emitting)

func _process(delta: float) -> void:
	# On récupère tous les émetteurs de chaleur actifs
	var heat_emitters = get_tree().get_nodes_in_group("heat_emitters")
	
	# On prépare les listes de données pour le shader
	var positions = []
	var radii = []
	
	for emitter in heat_emitters:
		# On ne garde que les émetteurs qui ont bien un HeatComponent
		var heat_component = emitter.get_node_or_null("HeatComponent")
		if heat_component:
			positions.append(emitter.global_position)
			radii.append(heat_component.heat_data.heat_radius)

	# On envoie les données au shader
	shader_material.set_shader_parameter("shield_count", positions.size())
	shader_material.set_shader_parameter("shield_positions", positions)
	shader_material.set_shader_parameter("shield_radii", radii)
