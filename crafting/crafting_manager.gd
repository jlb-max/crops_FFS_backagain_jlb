# res://managers/crafting_manager.gd
extends Node

var all_recipes: Dictionary = {}
var discovered_recipes_ids: Array[StringName] = []
const CraftingRecipe = preload("res://crafting/crafting_recipe.gd")
signal item_crafted(item_data: ItemData, quantity: int)

# Ce dictionnaire sera construit automatiquement au démarrage
var item_unlock_map: Dictionary = {}

func _ready() -> void:
	_load_all_recipes_from_disk()

func _load_all_recipes_from_disk() -> void:
	var dir_path = "res://crafting/recipes/"
	var dir = DirAccess.open(dir_path)
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres"):
				var recipe: CraftingRecipe = load(dir_path + file_name)
				if recipe and recipe.recipe_id != &"":
					all_recipes[recipe.recipe_id] = recipe
					
					# --- NOUVELLE LOGIQUE ---
					# Si la recette est "Toujours connue", on la découvre immédiatement
					if recipe.unlock_condition == CraftingRecipe.UnlockType.ALWAYS_KNOWN:
						discover_recipe(recipe.recipe_id)
					# Sinon, si elle est débloquée par un objet, on prépare notre dictionnaire
					elif recipe.unlock_condition == CraftingRecipe.UnlockType.ON_ITEM_DISCOVERY and recipe.unlocking_item != null:
						item_unlock_map[recipe.unlocking_item] = recipe.recipe_id
	
	print("CraftingManager: %d recettes chargées, %d recettes de base découvertes." % [all_recipes.size(), discovered_recipes_ids.size()])

# Nouvelle fonction appelée par InventoryManager
func on_item_added(item_data: ItemData):
	# On vérifie si l'objet ajouté est une clé de déblocage
	if item_unlock_map.has(item_data):
		var recipe_id_to_unlock = item_unlock_map[item_data]
		discover_recipe(recipe_id_to_unlock)

func discover_recipe(recipe_id: StringName) -> void:
	if not discovered_recipes_ids.has(recipe_id):
		discovered_recipes_ids.append(recipe_id)
		print("Nouvelle recette découverte : ", recipe_id)

func get_discovered_recipes() -> Array[CraftingRecipe]:
	var recipes: Array[CraftingRecipe] = []
	for id in discovered_recipes_ids:
		if all_recipes.has(id):
			recipes.append(all_recipes[id])
	return recipes

# Vérifie si une recette est faisable avec l'inventaire actuel
# (Nous supposons que vous avez un singleton InventoryManager)
func can_craft(recipe: CraftingRecipe) -> bool:
	if not recipe:
		return false
	for ingredient in recipe.ingredients:
		# --- VÉRIFICATION IMPORTANTE ---
		# On s'assure que l'ingrédient est bien un ItemData
		if not ingredient.item is ItemData:
			push_warning("L'ingrédient '%s' dans une recette n'est pas un ItemData valide." % ingredient.item)
			return false
		# --- FIN DE LA VÉRIFICATION ---

		var item_data: ItemData = ingredient.item # On peut maintenant le caster sans risque
		var required_quantity: int = ingredient.quantity
		
		if InventoryManager.get_item_count(item_data) < required_quantity:
			return false
	return true

# Tente de fabriquer un objet
func craft(recipe: CraftingRecipe) -> bool:
	if not can_craft(recipe):
		# On utilise .item_name
		push_warning("Cannot craft %s: not enough ingredients." % recipe.output_item.item_name)
		return false

	# 1. Consommer les ingrédients (déjà une boucle, c'est parfait)
	for ingredient in recipe.ingredients:
		InventoryManager.remove_item(ingredient.item, ingredient.quantity)
		
	# 2. Ajouter les objets fabriqués (MAINTENANT une boucle)
	for item_out in recipe.outputs:
		InventoryManager.add_item(item_out.item, item_out.quantity)
		item_crafted.emit(item_out.item, item_out.quantity)
		print("Crafted %d %s!" % [item_out.quantity, item_out.item.item_name])

	return true
