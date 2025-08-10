class_name PlacableItemComponent
extends Node

@export var game_tilemap: TileMapLayer
@export var objects_container: Node2D

func _ready():
	# On s'assure que le noeud écoute les inputs
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	# --- CORRECTION CLÉ ---
	# On écoute l'action "hit", comme pour vos plantes
	if event.is_action_pressed("hit"):
		
		# On vérifie si l'outil en main est bien un objet à poser
		if ToolManager.get_selected_action() == ItemData.ActionType.PLACE_CRAFTABLE:
			place_item()
			# On dit au jeu que l'input a été traité
			get_viewport().set_input_as_handled()

func place_item():
	var selected_item = ToolManager.get_selected_item()

	if not selected_item or not selected_item.scene_to_place:
		return

	var mouse_pos = game_tilemap.get_local_mouse_position()
	var map_coords = game_tilemap.local_to_map(mouse_pos)
	
	if objects_container:
		var new_object_instance = selected_item.scene_to_place.instantiate()
		objects_container.add_child(new_object_instance)
		new_object_instance.global_position = game_tilemap.map_to_local(map_coords)
		
		InventoryManager.remove_item(selected_item, 1)
