#fieldcursorcomponent.gd
class_name FieldCursorComponent
extends Node

@export var grass_tilemap_layer: TileMapLayer
@export var tilled_soil_tilemap_layer: TileMapLayer
@export var terrain_set: int = 0
@export var terrain: int = 3

@onready var player: Player 

signal action_requested(tile_coords: Vector2i)


var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")


func _unhandled_input(event: InputEvent) -> void:
	# On récupère l'action de l'item sélectionné UNE SEULE FOIS au début
	var current_action = ToolManager.get_selected_action()
	
	if current_action == ItemData.ActionType.WATER:
		if event.is_action_pressed("hit"): # Ou votre action de clic
			get_cell_under_mouse()

			# On vérifie que la tuile visée est bien de la terre labourable
			if tilled_soil_tilemap_layer.get_cell_source_id(cell_position) != -1:
				# On demande au manager de mouiller la tuile
				SoilManager.add_wet_tile(cell_position)

	if event.is_action_pressed("remove_dirt"):
		
		if current_action == ItemData.ActionType.TILL:
			get_cell_under_mouse()
			remove_tilled_soil_cell()
	
	elif event.is_action_pressed("hit"):
		
		if current_action == ItemData.ActionType.TILL:
			get_cell_under_mouse()
			add_tilled_soil_cell()



func get_cell_under_mouse() -> void:
	# 1. Position locale de la souris DANS le layer Grass (comme à l’origine)
	var mouse_pos = grass_tilemap_layer.get_local_mouse_position()

	# 2. Coordonnées de grille dans le layer Grass
	cell_position = grass_tilemap_layer.local_to_map(mouse_pos)
	cell_source_id = grass_tilemap_layer.get_cell_source_id(cell_position)

	# 3. Distance → on compare deux positions MONDE
	var tile_world = grass_tilemap_layer.map_to_local(cell_position)
	tile_world = grass_tilemap_layer.to_global(tile_world)
	distance = player.global_position.distance_to(tile_world)
	
	# DEBUG
	print("cell_position: ", cell_position, "  source: ", cell_source_id, "  dist: ", distance)

func add_tilled_soil_cell() -> void:
	if distance < 20.0 && cell_source_id != -1:
		tilled_soil_tilemap_layer.set_cells_terrain_connect([cell_position], terrain_set, terrain, true)

func remove_tilled_soil_cell() -> void:
	if distance < 20.0:
		tilled_soil_tilemap_layer.set_cells_terrain_connect([cell_position], 0, -1, true)
