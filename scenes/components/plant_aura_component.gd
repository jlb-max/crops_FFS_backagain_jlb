class_name PlantAuraComponent
extends EffectSource2D

var _owner_crop : PlantedCrop

func init_from_plant(crop: PlantedCrop) -> void:
	_owner_crop = crop
	var pd : PlantData = crop.plant_data

	# --- 1. Rayon maximum -------------------------------------------------
	effect_radius = 0.0
	if pd.heat_effect.emits_heat:
		effect_radius = max(effect_radius, pd.heat_effect.heat_radius)
	if pd.gravity_effect.has_gravity_effect:
		effect_radius = max(effect_radius, pd.gravity_effect.gravity_radius)
	# plus tard : rayon O₂

	# --- 2. Puissances -----------------------------------------------------
	heat_power    = 0.0
	if pd.heat_effect.emits_heat:
		heat_power = pd.heat_effect.heat_power

	gravity_power = 0.0
	if pd.gravity_effect.has_gravity_effect:
		gravity_power = pd.gravity_effect.gravity_influence
		
	

	oxygen_power  = 0.0      # placeholder → sera rempli quand tu ajouteras l’O₂
	
	EnvironmentManager.register(self)



func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		EnvironmentManager.unregister(self)
