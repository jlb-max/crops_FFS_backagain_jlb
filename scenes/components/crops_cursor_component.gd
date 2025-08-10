#corpscursorcomponent.gd
class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer: TileMapLayer

@onready var wetness_overlay_node: TileMapLayer = %WetnessOverlay

var player: Player

var crop_scene = preload("res://scenes/objects/plants/plantedcrop.tscn")


var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position : Vector2 
var distance: float 



func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	# On récupère l'action de l'item sélectionné UNE SEULE FOIS au début
	var current_action = ToolManager.get_selected_action()

	if event.is_action_pressed("remove_dirt"):
		# On vérifie si l'action de l'item est bien de labourer (TILL)
		if current_action == ItemData.ActionType.TILL:
			get_cell_under_mouse()
			remove_crop()
	
	elif event.is_action_pressed("hit"):
		# On vérifie si l'action de l'item est bien de planter (PLANT)
		if current_action == ItemData.ActionType.PLANT:
			get_cell_under_mouse()
			add_crop()


func get_cell_under_mouse() -> void:
	# Ces lignes pour trouver la case sont OK
	var mouse_pos = tilled_soil_tilemap_layer.get_local_mouse_position()
	cell_position = tilled_soil_tilemap_layer.local_to_map(mouse_pos)
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	
	# --- CORRECTION ---
	# 1. On calcule la position LOCALE du coin de la tuile
	var local_cell_pos = tilled_soil_tilemap_layer.map_to_local(cell_position)
	
	# 2. On la convertit en position MONDIALE
	var world_pos_of_cell = tilled_soil_tilemap_layer.to_global(local_cell_pos)
	
	# 3. On calcule la distance entre deux positions MONDIALES. Ce calcul est maintenant juste.
	distance = player.global_position.distance_to(world_pos_of_cell)
	
	print("mouse_position: ", mouse_position, " cell_position: ", cell_position, " cell_source_id: ", cell_source_id)
	print("distance: ", distance)


func add_crop() -> void:
	# --- Vérification de la distance (ne change pas) ---
	if distance >= 20.0:
		return
	if CropManager.is_tile_occupied(cell_position):
		print("ACTION ANNULÉE: Une plante est déjà présente sur cette tuile.")
		return
	# --- Nouvelle logique Data-Driven ---
	
	# 1. On récupère l'item actuellement sélectionné par le joueur
	var selected_item: ItemData = ToolManager.get_selected_item() # Assurez-vous que ToolManager renvoie bien un ItemData

	# 2. On vérifie si l'item est bien une graine valide
	if not selected_item or not selected_item.plant_to_grow:
		# Si aucun item n'est tenu, ou si l'item n'a pas de "recette" de plante, on s'arrête.
		return
		
	# 3. On vérifie qu'on est bien sur de la terre labourée
	if tilled_soil_tilemap_layer.get_cell_source_id(cell_position) == -1:
		return
		

	# 4. On récupère la recette (le PlantData) depuis l'item
	var plant_recipe: PlantData = selected_item.plant_to_grow
	
	# 5. On instancie notre scène générique
	var crop_instance = crop_scene.instantiate()
	
	# 6. On injecte la recette dans la nouvelle plante pour qu'elle sache ce qu'elle est
	crop_instance.plant_data = plant_recipe
	crop_instance.wetness_overlay = wetness_overlay_node


	
	# 7. On trouve le conteneur et on ajoute la plante
	var crop_fields_node = get_parent().find_child("CropFields")
	if crop_fields_node:
		crop_fields_node.add_child(crop_instance)
		var local_cell_pos = tilled_soil_tilemap_layer.map_to_local(cell_position)
		crop_instance.global_position = tilled_soil_tilemap_layer.to_global(local_cell_pos)
		CropManager.register_crop(cell_position, crop_instance)
		InventoryManager.remove_item(selected_item, 1)
		
		print("Plantation de '", plant_recipe.item_name, "' réussie.")
	else:
		print("ERREUR: Le noeud 'CropFields' est introuvable pour y placer la plante.")
		




func remove_crop() -> void:
	if distance < 20.0:
		var crop_nodes = get_parent().find_child("CropFields").get_children()
		
		for node: PlantedCrop in crop_nodes:
			# On recalcule la position de la grille de chaque plante pour trouver la bonne
			var node_cell = tilled_soil_tilemap_layer.local_to_map(tilled_soil_tilemap_layer.to_local(node.global_position))
			if node_cell == cell_position:
				node.queue_free()
				return
