class_name WaterPulseComponent
extends Node2D

@onready var pulse_timer: Timer = $PulseTimer
# La référence pointe maintenant vers un ColorRect
@onready var water_sphere: Sprite2D = $WaterSphere


var plant_data: PlantData
const TILE_SIZE = 16 # Mettez ici la taille en pixels de vos tuiles

func _ready():
	water_sphere.visible = false
	pulse_timer.timeout.connect(start_water_pulse)

# Nouvelle fonction pour initialiser le composant
func initialize(p_plant_data: PlantData):
	plant_data = p_plant_data
	
	if not plant_data or not plant_data.water_pulse_effect:
		return
	
	# On s'assure que le sprite a bien une texture
	if not water_sphere.texture:
		push_error("La WaterSphere (Sprite2D) n'a pas de texture de base !")
		return

	# --- NOUVEAU CALCUL DE TAILLE AVEC SCALE ---
	var radius = plant_data.water_pulse_effect.pulse_radius
	var diameter_in_tiles = (radius * 2) + 1
	var target_diameter_in_pixels = diameter_in_tiles * TILE_SIZE
	
	# On calcule le ratio d'agrandissement nécessaire
	var texture_size = water_sphere.texture.get_size().x # On suppose une texture carrée
	var required_scale = target_diameter_in_pixels / texture_size
	
	# On applique le scale
	water_sphere.scale = Vector2(required_scale, required_scale)
	
	# Un Sprite2D est centré par défaut, donc la position locale peut rester à (0,0)
	water_sphere.position = Vector2.ZERO

func start_water_pulse():
	if not plant_data or not plant_data.water_pulse_effect:
		return

	water_sphere.visible = true

	var tween = create_tween()
	tween.tween_property(water_sphere.material, "shader_parameter/growth", 1.0, plant_data.water_pulse_effect.pulse_duration) \
		 .from(0.0) \
		 .set_trans(Tween.TRANS_CUBIC) \
		 .set_ease(Tween.EASE_OUT)

	tween.tween_callback(release_water)

func release_water():
	# Cacher la sphère
	water_sphere.visible = false
	water_sphere.material.set_shader_parameter("growth", 0.0)
	
	# Logique d'arrosage des tuiles autour
	var radius = plant_data.water_pulse_effect.pulse_radius
	var origin_tile = SoilManager.get_tile_coords(global_position)
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var target_tile = origin_tile + Vector2i(x, y)
			SoilManager.add_wet_tile(target_tile)
	
	# On pourrait ajouter un effet de particules d'éclaboussure ici
	print("La plante a arrosé les tuiles environnantes !")
