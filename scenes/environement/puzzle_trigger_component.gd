class_name PuzzleTriggerComponent
extends Area2D

@export var required_plant: PlantData
@export var template_scene_to_apply: PackedScene
@export var target_game_tilemap: Node2D   # parent Node2D qui contient les TileMapLayer

var listening_to_plant: PlantedCrop = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# --------------------------------------------------------------------------
# 1. Détection d’entrée / sortie dans la zone
# --------------------------------------------------------------------------
func _on_area_entered(area: Area2D) -> void:
	if area.owner is PlantedCrop and area.owner.plant_data == required_plant:
		listening_to_plant = area.owner as PlantedCrop
		listening_to_plant.growth_cycle_component.crop_harvesting.connect(on_puzzle_solved)

func _on_area_exited(area: Area2D) -> void:
	if area.owner == listening_to_plant:
		if is_instance_valid(listening_to_plant):
			var sig = listening_to_plant.growth_cycle_component.crop_harvesting
			if sig.is_connected(on_puzzle_solved):
				sig.disconnect(on_puzzle_solved)
		listening_to_plant = null

# --------------------------------------------------------------------------
# 2. Logique : apparition du pont
# --------------------------------------------------------------------------
func on_puzzle_solved() -> void:
	# 0. Vérifications
	if not template_scene_to_apply or not target_game_tilemap:
		return

	# 1. Couches nécessaires
	var template: TileMapLayer = template_scene_to_apply.instantiate()
	var water_layer := target_game_tilemap.find_child("Water") as TileMapLayer
	var grass_layer := target_game_tilemap.find_child("Grass") as TileMapLayer
	if not water_layer or not grass_layer:
		push_error("Couches « Water » ou « Grass » introuvables.")
		template.queue_free()
		return

	# 2. Cases du pont + voisines
	var cell_set: Dictionary = {}
	var template_cells: Array[Vector2i] = template.get_used_cells()
	for cell in template_cells:
		cell_set[cell] = true
		for n in grass_layer.get_surrounding_cells(cell):
			cell_set[n] = true
	var bridge_cells: Array[Vector2i] = []
	bridge_cells.assign(cell_set.keys())

	# 3. Groupes par terrain
	var by_terrain: Dictionary = {}
	for cell in template_cells:
		var td := template.get_cell_tile_data(cell)
		if td == null:
			continue
		var key := Vector2i(td.terrain_set, td.terrain)
		by_terrain[key] = by_terrain.get(key, []) + [cell]

	## 4. Efface l’eau
	#for cell in bridge_cells:
		#water_layer.erase_cell(cell)

	# 5. Peint le pont (terrain connect)
	for key: Vector2i in by_terrain.keys():
		grass_layer.set_cells_terrain_connect(
			by_terrain[key],
			key.x,   # terrain_set
			key.y    # terrain_id
		)

	# 6. Rafraîchit immédiatement
	grass_layer.update_internals()

	# 7. Nettoyage
	template.queue_free()
	queue_free()            # supprime le trigger (facultatif)
