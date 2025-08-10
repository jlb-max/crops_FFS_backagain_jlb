# GrowthCycleComponent.gd (Version avec débogage intégré)
class_name GrowthCycleComponent
extends Node

signal growth_stage_changed(new_stage: int)
signal crop_harvesting


@export var total_stages: int = 4

var tile_coords: Vector2i
var current_growth_state: int = 0
var days_watered: int = 0
var is_watered_today: bool = false
var is_harvestable: bool = false
var wetness_overlay: TileMapLayer
var growth_modifier: float = 1.0
var plant_data_ref: PlantData
var planted_crop: Node

func _ready() -> void:
	planted_crop = get_owner()
	# 1. Connexion à l’horloge
	DayAndNightCycleManager.time_tick_day.connect(on_day_passed)

func _ensure_tile_coords() -> void:
	if wetness_overlay and tile_coords == Vector2i():
		var local_pos  = wetness_overlay.to_local(get_parent().global_position)
		tile_coords = wetness_overlay.local_to_map(local_pos)

# Appelée par PlantedCrop quand la plante est arrosée
func set_watered_state(is_watered: bool) -> void:
	is_watered_today = is_watered
	print("DEBUG (GrowthCycle): L'état 'is_watered_today' est maintenant à ", is_watered_today)

# Appelée chaque nouveau jour par le signal de l'horloge
func on_day_passed(day: int = -1) -> void:
	# --- TEST DE DÉBOGAGE ---
	# Si la fonction est appelée sans numéro de jour, c'est notre coupable !
	if planted_crop.is_dead:
		return
	
	if day == -1:
		push_error("ERREUR DE CONNEXION : on_day_passed a été appelé par un signal incorrect qui n'a pas fourni de numéro de jour !")
		return # On arrête tout pour ne pas créer plus de bugs.
		
	if not plant_data_ref:
		return

	# Si la plante n'est pas récoltable, on continue
	if is_harvestable:
		return

	# Étape 1 : Vérifier si la plante est arrosée
	_ensure_tile_coords()
	var is_watered = is_watered_today or SoilManager.is_tile_wet(tile_coords)
	
	# Si la plante n'est PAS arrosée, on arrête TOUT ici. Pas d'eau, pas de croissance.
	if not is_watered:
		print("--- NOUVEAU JOUR %d --- Plante non arrosée. Pas de croissance." % day)
		is_watered_today = false # Réinitialisation pour le jour suivant
		return

	# À partir d'ici, on sait que la plante EST arrosée.
	print("--- NOUVEAU JOUR %d --- Plante arrosée." % day)
	var plant_pos := (get_parent() as Node2D).global_position
	var eff := EnvironmentManager.get_local_effects(plant_pos)
	
	print("DEBUG GERMINATION: Effets d'environnement reçus pour la plante: ", eff)

	# Étape 2 : Gérer la croissance selon le stade
	if current_growth_state == 0:
		# --- CAS SPÉCIAL : GERMINATION ---
		# On vérifie si les conditions de l'environnement sont remplies
		if eff.heat >= plant_data_ref.min_heat and \
		   eff.oxygen >= plant_data_ref.min_oxygen and \
		   eff.gravity >= plant_data_ref.min_gravity:
			
			# Succès ! La plante germe.
			print("  Conditions de germination remplies. La plante germe.")
			days_watered += 1
			check_for_growth()
		else:
			# Échec. La plante est arrosée mais l'environnement n'est pas bon.
			print("  Conditions de germination NON remplies (Chaleur: %.1f/%.1f). Pas de croissance." % [eff.heat, plant_data_ref.min_heat])
			# On ne fait rien d'autre. La plante ne pousse pas.

	else:
		# --- CAS NORMAL : CROISSANCE (stade > 0) ---
		print("  La plante continue de grandir.")
		days_watered += 1
		_apply_environment_effects(eff)
		check_for_growth()

	# Étape 3 : Réinitialisation pour le jour suivant
	is_watered_today = false


func _apply_environment_effects(eff: Dictionary) -> void:
	# 0. Valeur neutre
	growth_modifier = 1.0

	# ---------- Chaleur ----------
	var s := plant_data_ref.heat_effect.heat_sensitivity
	if s != 0.0:
		var delta : float = eff.heat / 10.0      # « 10 » = échelle empirique
		growth_modifier += delta * s      # bonus ou malus

		# dégâts optionnels
		if s < 0.0 and delta > 0.5:       # la plante déteste la chaleur ?
			_take_stress_damage(delta)

	# ---------- Oxygène ----------
	s = plant_data_ref.oxygen_effect.oxygen_sensitivity
	if s != 0.0:
		var delta : float = eff.oxygen / 10.0
		growth_modifier += delta * s
		if s < 0.0 and delta > 0.5:
			_take_stress_damage(delta)

	# ---------- Gravité ----------
	s = plant_data_ref.gravity_effect.gravity_sensitivity
	if s != 0.0:
		var delta : float = eff.gravity / 10.0
		growth_modifier += delta * s
		if s < 0.0 and delta > 0.5:
			_take_stress_damage(delta)

	# Clamp pour éviter des bonus absurdes
	growth_modifier = clamp(growth_modifier, 0.25, 3.0)

func _take_stress_damage(intensity: float) -> void:
	# Ici on peut : réduire la santé, jouer une anim, etc.
	# Pour l’instant un simple log :
	if Engine.is_editor_hint():
		print("⚠️  Stress sur la plante :", intensity)


# La logique de croissance
func check_for_growth() -> void:
	# 1. Jours nécessaires pour mûrir (>=1)
	var days_needed : int = max(
		1,
		int(ceil(float(plant_data_ref.growth_data.time_to_maturity) / growth_modifier))
	)

	# 2. Jours par stade (>=1)
	var days_stage : int = max(
		1,
		int(ceil(float(days_needed) / float(total_stages)))
	)

	# 3. Stade atteint
	var calculated_stage : int = clamp(
		days_watered / days_stage, 0, total_stages
	)

	print("  Croissance : stade calculé=", calculated_stage,
		  " | actuel=",  current_growth_state,
		  " (", days_watered, "/", days_needed, " jours)")

	# 4. Mise à jour éventuelle
	if calculated_stage > current_growth_state:
		current_growth_state = calculated_stage
		growth_stage_changed.emit(current_growth_state)
		print("  ► CHANGEMENT ► Stade ", current_growth_state)

		if current_growth_state >= total_stages:
			is_harvestable = true
			crop_harvesting.emit()



func apply_growth_modifier(bonus: float) -> void:
	growth_modifier += bonus

func apply_heat_modifier(external_heat_power: float):
	# La plante a besoin de ses propres données pour savoir comment réagir
	var sensitivity = plant_data_ref.heat_effect.heat_sensitivity
	
	if sensitivity != 0:
		# Calcule le bonus/malus de croissance
		var growth_bonus = external_heat_power * sensitivity
		# Applique le modificateur (vous avez déjà une variable growth_modifier)
		growth_modifier += growth_bonus
