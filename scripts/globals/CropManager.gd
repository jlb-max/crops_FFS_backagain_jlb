# CropManager.gd
extends Node

# Un dictionnaire qui stockera les plantes par coordonnées.
# Format: { Vector2i(x, y): Node }
var planted_crops = {}

# Fonction pour vérifier si une tuile est occupée.
func is_tile_occupied(coords: Vector2i) -> bool:
	return planted_crops.has(coords)

# Fonction pour enregistrer une nouvelle plante dans le registre.
func register_crop(coords: Vector2i, crop_node: Node2D) -> void:
	planted_crops[coords] = crop_node
	print("INFO (CropManager): Plante enregistrée à la position ", coords)
	print("DEBUG (CropManager): Plante enregistrée à ", coords, ". Registre actuel: ", planted_crops)

# Fonction pour retirer une plante du registre (quand elle est récoltée/détruite).
func unregister_crop(coords: Vector2i) -> void:
	if planted_crops.has(coords):
		planted_crops.erase(coords)
		print("INFO (CropManager): Plante désenregistrée de la position ", coords)

func on_day_passed(day: int) -> void:
	var emitters = [] # Liste des plantes qui émettent de la lumière

	# On identifie d'abord toutes les sources de lumière
	for crop in planted_crops.values():
		if crop.plant_data.light_emission > 0:
			emitters.append(crop)
	
	if emitters.size() == 0:
		return # S'il n'y a aucune lumière, on ne fait rien

	# Maintenant, on calcule l'effet de chaque source sur toutes les plantes
	for crop_receiver in planted_crops.values():
		for crop_emitter in emitters:
			if crop_receiver == crop_emitter:
				continue # Une plante ne s'influence pas elle-même

			var distance = crop_receiver.global_position.distance_to(crop_emitter.global_position)
			
			# Si le receveur est dans le rayon de l'émetteur...
			if distance <= crop_emitter.plant_data.light_influence_radius:
				var bonus = crop_emitter.plant_data.light_growth_bonus
				var sensitivity = crop_receiver.plant_data.light_sensitivity
				
				# On applique le bonus, modulé par la sensibilité de la plante qui reçoit
				crop_receiver.growth_cycle_component.apply_growth_modifier(bonus * sensitivity)
