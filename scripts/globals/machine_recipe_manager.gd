extends Node

var all_recipes: Dictionary = {}
var discovered_recipe_ids: Array[String] = [] # On utilise le chemin du fichier (String)

func _ready():
	_load_all_recipes()

func _load_all_recipes():
	var dir = DirAccess.open("res://machines/recipes/")
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tres"):
				var recipe: MachineRecipe = load("res://machines/recipes/" + file)
				# On utilise le chemin du fichier comme ID unique et permanent
				all_recipes[recipe.resource_path] = recipe
				
				# --- NOUVELLE LOGIQUE ---
				# Si la recette doit être connue dès le début, on la découvre
				if recipe.unlock_condition == MachineRecipe.UnlockType.ALWAYS_KNOWN:
					discover_recipe(recipe)

func discover_recipe(recipe: MachineRecipe):
	var id = recipe.resource_path
	if not discovered_recipe_ids.has(id):
		discovered_recipe_ids.append(id)
		print("Nouvelle recette de machine apprise : ", recipe.resource_path)

func get_discovered_recipes_for_machine(type: StringName) -> Array[MachineRecipe]:
	var discovered: Array[MachineRecipe] = []
	for id in discovered_recipe_ids:
		if all_recipes.has(id):
			var recipe = all_recipes[id]
			# On ajoute la recette à la liste seulement si son type correspond
			if recipe.machine_type == type:
				discovered.append(recipe)
	return discovered
