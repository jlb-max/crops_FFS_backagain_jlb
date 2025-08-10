#crafting_ui.gd

extends Control

@onready var recipe_grid: GridContainer = $RecipeGridContainer
@export var recipe_detail_window: PanelContainer

var recipe_slot_scene = preload("res://scenes/ui/inventoryslot.tscn")
# On définit une taille fixe pour la grille de craft, comme pour l'inventaire
var crafting_grid_size: int = 20 

func _ready():
	# --- NOUVEAU : On pré-remplit la grille ---
	for i in range(crafting_grid_size):
		var slot = recipe_slot_scene.instantiate()
		recipe_grid.add_child(slot)
		# On connecte le signal du slot une seule fois, ici.
		slot.recipe_selected.connect(on_recipe_slot_selected)
		slot.display_empty() # On s'assure qu'il est vide au départ

	# On se connecte toujours au signal de visibilité pour rafraîchir
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		redraw_crafting_grid()

# --- MODIFICATION MAJEURE de la fonction de redessin ---
func redraw_crafting_grid():
	var discovered_recipes = CraftingManager.get_discovered_recipes()
	var slots = recipe_grid.get_children()

	# On parcourt tous les slots de la grille
	for i in range(slots.size()):
		var slot_node = slots[i]
		
		# S'il y a une recette à afficher pour ce slot...
		if i < discovered_recipes.size():
			slot_node.display_recipe(discovered_recipes[i])
		# Sinon, on s'assure que le slot est vide
		else:
			slot_node.display_empty()

func on_recipe_slot_selected(recipe: CraftingRecipe):
	# Cette fonction ne change pas
	recipe_detail_window.show_recipe_details(recipe)
