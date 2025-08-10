# machine_recipe.gd

@tool
class_name MachineRecipe
extends Resource

# On réutilise la même ressource Ingredient que pour le crafting
const Ingredient = preload("res://crafting/ingredient.gd") 

enum UnlockType { ALWAYS_KNOWN, BY_REWARD }
@export var unlock_condition: UnlockType = UnlockType.ALWAYS_KNOWN

@export_group("Entrée(s)")
@export var inputs: Array[Ingredient]

@export_group("Sortie(s)")
@export var outputs: Array[Ingredient]

@export_group("Paramètres")
@export var processing_time_seconds: float = 10.0
@export var machine_type: StringName # ex: "BioFuelConverter", "Atelier", "Fonderie"
