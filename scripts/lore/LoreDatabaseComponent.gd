# scripts/lore/LoreDatabaseComponent.gd
extends Node

# Ce tableau contiendra la liste de TOUTES les plantes du jeu qui ont du lore.
var all_lore_plants: Array[PlantData] = []

func _ready():
	# On se met dans un groupe pour que le Codex puisse nous trouver facilement
	add_to_group("lore_database")
	# On scanne le projet une seule fois au démarrage
	_scan_for_lore_plants()

# Scanne le dossier des plantes pour trouver celles qui ont du lore
func _scan_for_lore_plants():
	all_lore_plants.clear()
	var plant_dir_path = "res://scenes/objects/plants/"

	var dir = DirAccess.open(plant_dir_path)
	if dir:
		for file_name in dir.get_files():
			# On ne charge que les fichiers de données des plantes
			if file_name.ends_with("_data.tres"):
				var plant_res = load(plant_dir_path.path_join(file_name))
				# Si la ressource est valide et qu'elle a un LoreData attaché...
				if is_instance_valid(plant_res) and plant_res.lore_data:
					all_lore_plants.append(plant_res)

	print("Lore Database initialisée : %d plantes avec du lore trouvées." % all_lore_plants.size())
