# ItemData.gd
@tool
class_name ItemData
extends CollectibleData

enum ActionType { NONE, TILL, WATER, PLANT, CHOP, PLACE_CRAFTABLE }

@export var scene_to_place: PackedScene



@export var damage: int = 1

@export var action_type: ActionType = ActionType.NONE
@export var plant_to_grow: PlantData

@export_group("Origine de la Plante")
## Si cet item est un produit de plante, liez ici le PlantData correspondant.
@export_file("*.tres") var source_plant_data_path: String
var _source_plant_data_cache: PlantData = null

func get_source_plant_data() -> PlantData:
	# Si le cache est vide et que le chemin n'est pas vide
	if _source_plant_data_cache == null and not source_plant_data_path.is_empty():
		# On charge la ressource depuis le chemin et on la met en cache
		_source_plant_data_cache = load(source_plant_data_path)
	return _source_plant_data_cache
