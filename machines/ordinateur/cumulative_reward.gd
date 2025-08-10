# cumulative_reward.gd
@tool
class_name CumulativeReward
extends Resource

const Ingredient = preload("res://crafting/ingredient.gd")

# La quantité de carburant nécessaire pour atteindre ce palier
@export var fuel_required: Array[Ingredient]

@export_group("Récompenses")
# Une liste d'items à donner directement
@export var reward_items: Array[Ingredient]
# Une liste de recettes de craft à débloquer
@export var reward_crafting_recipes: Array[CraftingRecipe]
@export var reward_machine_recipes: Array[MachineRecipe]
