@tool
class_name CraftingRecipe
extends Resource

const Ingredient = preload("res://crafting/ingredient.gd")

# On définit les différentes manières de débloquer une recette
enum UnlockType { ALWAYS_KNOWN, ON_ITEM_DISCOVERY }

@export_group("Outputs")
@export var outputs: Array[Ingredient]

@export_group("Ingredients")
@export var ingredients: Array[Ingredient]

@export_group("Unlocking")
@export var recipe_id: StringName
# Un menu déroulant apparaîtra dans l'inspecteur !
@export var unlock_condition: UnlockType = UnlockType.ON_ITEM_DISCOVERY
# Ce champ n'apparaîtra que si on choisit ON_ITEM_DISCOVERY
@export var unlocking_item: ItemData:
	set(value):
		unlocking_item = value
		notify_property_list_changed()

# Cette fonction avancée permet de cacher/montrer des variables dans l'inspecteur
func _get_property_list():
	var properties = []
	if unlock_condition == UnlockType.ON_ITEM_DISCOVERY:
		properties.append({
			"name": "unlocking_item",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "ItemData"
		})
	return properties
