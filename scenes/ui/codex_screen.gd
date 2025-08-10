# CodexScreen.gd (Version finale)
extends HSplitContainer

# Références aux nœuds de l'interface
@onready var plant_list: ItemList = $VBoxContainer/PlantList
@onready var plant_name_label: Label = $VBoxContainer2/PlantNameLabel
@onready var progress_bar: TextureProgressBar = $VBoxContainer2/SequencingProgressBar
@onready var lore_text_label: RichTextLabel = $VBoxContainer2/LoreTextLabel

# On stocke les données des plantes pour y accéder facilement
var plant_data_array: Array[PlantData] = []
const GARBLE_CHARS = "▒▓█_?"

func _ready():
	plant_list.item_selected.connect(_on_plant_selected)
	populate_plant_list()
	# On sélectionne le premier item par défaut pour afficher quelque chose
	if not plant_data_array.is_empty():
		plant_list.select(0)
		_on_plant_selected(0)

# Remplit la liste avec les plantes que le joueur a découvertes
func populate_plant_list():
	plant_list.clear()
	plant_data_array.clear()
	
	var all_known_plants = get_all_plant_data_from_game()
	
	for plant in all_known_plants:
		# --- CORRECTION : On vérifie que la ressource a bien été chargée ---
		if not is_instance_valid(plant):
			push_warning("Une plante dans get_all_plant_data_from_game() n'a pas pu être chargée. Vérifiez les chemins de fichiers.")
			continue # On ignore cette entrée et on passe à la suivante

		# Le reste de la logique ne change pas
		if plant.lore_data:
			plant_data_array.append(plant)
			plant_list.add_item(plant.item_name, plant.icon)

# Appelée quand le joueur clique sur une plante dans la liste
func _on_plant_selected(index: int):
	var selected_plant = plant_data_array[index]
	
	plant_name_label.text = selected_plant.item_name
	
	var progress = LoreManager.get_sequencing_progress(selected_plant)
	var required = selected_plant.lore_data.sequencing_points_required
	
	# --- LIGNE DE DÉBOGAGE À AJOUTER ---
	print("CODEX DEBUG: Plante sélectionnée: '%s', Progression récupérée: %d / %d" % [selected_plant.item_name, progress, required])
	
	progress_bar.max_value = required
	progress_bar.value = progress
	
	lore_text_label.text = get_revealed_text(selected_plant)

# Fonction corrigée pour révéler le texte
func get_revealed_text(plant_data: PlantData) -> String:
	if not plant_data or not plant_data.lore_data:
		return "Aucune donnée."

	var full_text = plant_data.lore_data.full_text
	var required = float(plant_data.lore_data.sequencing_points_required)
	var progress = float(LoreManager.get_sequencing_progress(plant_data))

	if required == 0:
		return full_text
	
	var progress_percent = clamp(progress / required, 0.0, 1.0)
	if progress_percent >= 1.0:
		return full_text

	# --- LOGIQUE DE MOTS ALÉATOIRES CORRIGÉE ---
	var words = full_text.split(" ", false)
	var word_count = words.size()
	var word_indices = range(word_count)
	
	# --- CORRECTION CI-DESSOUS ---
	# 1. On utilise le chemin de la ressource comme "graine" pour le mélange.
	seed(hash(plant_data.resource_path))
	# 2. On mélange les indexes en utilisant la graine globale qu'on vient de définir.
	word_indices.shuffle()
	# 3. TRÈS IMPORTANT: On réinitialise le générateur aléatoire pour le reste du jeu.
	randomize()
	# --- FIN DE LA CORRECTION ---

	var words_to_reveal_count = int(word_count * progress_percent)
	var revealed_indices = {}
	for i in range(words_to_reveal_count):
		revealed_indices[word_indices[i]] = true

	var final_text = ""
	for i in range(word_count):
		if revealed_indices.has(i):
			final_text += words[i] + " "
		else:
			final_text += "▒".repeat(words[i].length()) + " "
			
	return final_text

# Fonction d'exemple pour charger les plantes - À ADAPTER
func get_all_plant_data_from_game() -> Array[PlantData]:
	var discovered_lore_plants: Array[PlantData] = []
	
	# 1. On trouve notre base de données via son groupe
	var lore_db = get_tree().get_first_node_in_group("lore_database")
	if not lore_db:
		push_warning("LoreDatabaseComponent introuvable dans la scène !")
		return []
		
	# 2. On parcourt toutes les plantes possibles du jeu
	for plant in lore_db.all_lore_plants:
		# 3. On vérifie si le joueur a déjà fait au moins 1 point de progression
		if LoreManager.get_sequencing_progress(plant) > 0:
			# Si oui, on l'ajoute à la liste à afficher
			discovered_lore_plants.append(plant)
			
	return discovered_lore_plants

func refresh_display():
	# 1. On mémorise l'item qui est actuellement sélectionné, s'il y en a un.
	var previously_selected_plant: PlantData = null
	var selected_indices = plant_list.get_selected_items()
	if not selected_indices.is_empty():
		previously_selected_plant = plant_data_array[selected_indices[0]]

	# 2. On repeuple la liste de gauche (ce qui efface la sélection actuelle).
	populate_plant_list()

	# 3. On essaie de retrouver et de re-sélectionner l'item précédent.
	if previously_selected_plant:
		var new_index = plant_data_array.find(previously_selected_plant)
		if new_index != -1:
			# On sélectionne l'item dans la liste visuelle
			plant_list.select(new_index)
			# On appelle manuellement la fonction de mise à jour des détails
			_on_plant_selected(new_index)
			return # On a fini, pas besoin d'aller plus loin

	# 4. Si rien n'était sélectionné ou si l'item a disparu, on sélectionne le premier de la liste.
	if not plant_data_array.is_empty():
		plant_list.select(0)
		_on_plant_selected(0)
	else:
		# S'il n'y a plus rien dans la liste, on vide le panneau de droite.
		plant_name_label.text = "Aucune plante séquencée"
		progress_bar.value = 0
		lore_text_label.text = ""
