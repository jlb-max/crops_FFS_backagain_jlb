# reward_machine_component.gd
class_name RewardMachineComponent
extends Node

signal progress_updated(current_progress, required_amount)


# La liste ordonnée des paliers de récompense
@export var reward_tiers: Array[CumulativeReward]

# --- Variables de sauvegarde ---
var current_tier_index: int = 0
var progress_per_item: Dictionary = {}

func add_item(item_to_add: ItemData, quantity_to_add: int):
	if current_tier_index >= reward_tiers.size():
		print("Tous les paliers ont été atteints.")
		return
	
	var requirements = get_current_requirements()
	
	# --- AJOUT DE DÉBOGAGE ---
	print("--- Début de la vérification des prérequis ---")
	print("Tier actuel: ", current_tier_index)
	print("Item soumis par le joueur: ", item_to_add)
	print("Liste des prérequis pour ce tier: ", requirements)
	for i in requirements.size():
		var req = requirements[i]
		print("  - Prérequis N°%d: Ingrédient=%s, Item=%s, Quantité=%d" % [i, req, req.item, req.quantity])
	print("-----------------------------------------")
	# --- FIN DU DÉBOGAGE ---

	var is_required = false
	for ingredient in get_current_requirements():
		# --- CORRECTION CI-DESSOUS ---
		# Ancien code : if ingredient.item == item_to_add:
		# Nouveau code :
		if ingredient.item.resource_path == item_to_add.resource_path:
			is_required = true
			break
	
	if not is_required:
		print("Item non requis pour ce palier.")
		return

	# Le reste de la fonction ne change pas
	var in_inventory = InventoryManager.get_item_count(item_to_add)
	var quantity_taken = min(quantity_to_add, in_inventory)

	if quantity_taken > 0:
		InventoryManager.remove_item(item_to_add, quantity_taken)
		
		if not progress_per_item.has(item_to_add):
			progress_per_item[item_to_add] = 0
		progress_per_item[item_to_add] += quantity_taken

		check_for_reward()
		progress_updated.emit(progress_per_item, get_current_requirements())


# Vérifie si le palier actuel est atteint
func check_for_reward():
	if current_tier_index >= reward_tiers.size():
		return

	var requirements = get_current_requirements()
	var all_requirements_met = true

	# On vérifie chaque ingrédient requis
	for ingredient in requirements:
		var submitted_amount = progress_per_item.get(ingredient.item, 0)
		if submitted_amount < ingredient.quantity:
			all_requirements_met = false
			break # Pas la peine de continuer si un seul manque
	
	if all_requirements_met:
		_grant_rewards()

func _grant_rewards():
	var completed_tier = reward_tiers[current_tier_index]

	# --- MODIFIÉ : On "consomme" les items du dictionnaire de progression ---
	for ingredient in completed_tier.fuel_required:
		progress_per_item[ingredient.item] -= ingredient.quantity

	# Donner les items (ne change pas)
	for item_reward in completed_tier.reward_items:
		InventoryManager.add_item(item_reward.item, item_reward.quantity)
		print("Récompense obtenue : ", item_reward.item.item_name)

	# Débloquer les recettes (ne change pas)
	for recipe_reward in completed_tier.reward_crafting_recipes:
		CraftingManager.discover_recipe(recipe_reward.recipe_id)
	for machine_recipe_reward in completed_tier.reward_machine_recipes:
		MachineRecipeManager.discover_recipe(machine_recipe_reward)

	# Passer au palier suivant
	current_tier_index += 1

	# S'il reste des items en "trop", on revérifie pour le nouveau palier
	check_for_reward()


func get_current_requirements() -> Array[Ingredient]:
	if current_tier_index < reward_tiers.size():
		return reward_tiers[current_tier_index].fuel_required
	return [] # Retourne une liste vide si tout est complété
