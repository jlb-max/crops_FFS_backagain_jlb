# scripts/globals/lore_manager.gd
extends Node

# Dictionnaire qui stockera la progression.
# Clé: le chemin du fichier PlantData (ex: "res://.../carot_data.tres")
# Valeur: les points de séquençage actuels (int)
var sequencing_progress: Dictionary = {}

# Ajoute des points de progression pour une plante donnée
func add_sequencing_progress(plant_data: PlantData, points_to_add: int):
	if not plant_data: return

	var path = plant_data.resource_path
	if not sequencing_progress.has(path):
		sequencing_progress[path] = 0

	var required = plant_data.lore_data.sequencing_points_required
	sequencing_progress[path] = min(sequencing_progress[path] + points_to_add, required)
	print("Progression pour %s : %d / %d" % [plant_data.item_name, sequencing_progress[path], required])

# Récupère la progression pour une plante
func get_sequencing_progress(plant_data: PlantData) -> int:
	if not plant_data: return 0
	return sequencing_progress.get(plant_data.resource_path, 0)
