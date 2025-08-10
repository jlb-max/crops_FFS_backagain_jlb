# recipe_detail_window.gd
extends PanelContainer

# --- Références aux noeuds enfants ---
@onready var output_items_list: HBoxContainer = $VBoxContainer/OutputItemsList

@onready var ingredients_list: HBoxContainer = $VBoxContainer/IngredientsList
@onready var craft_button: Button = $VBoxContainer/CraftButton
@onready var close_button: Button = $VBoxContainer/CloseButton

@export var inventory_panel: PanelContainer


# --- Variables ---
var current_recipe: CraftingRecipe = null
const INGREDIENT_SLOT_SCENE = preload("res://scenes/ui/inventoryslot.tscn") # Utilisez votre scène de slot simplifiée

# --- Initialisation ---
func _ready() -> void:
	# On connecte les signaux des boutons à leurs fonctions
	craft_button.pressed.connect(_on_craft_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# La fenêtre est cachée au démarrage
	visible = false

# --- Fonctions Publiques ---
# C'est LA fonction que crafting_ui.gd appelle
func show_recipe_details(recipe: CraftingRecipe):
	self.global_position.y = inventory_panel.global_position.y
	self.global_position.x = inventory_panel.global_position.x + inventory_panel.size.x + 10
	
	current_recipe = recipe
	show()
	
	# --- NOUVELLE LOGIQUE D'AFFICHAGE DES SORTIES ---
	# On vide la liste des anciennes sorties
	for child in output_items_list.get_children():
		child.queue_free()
	
	# On remplit avec les nouvelles sorties
	for output_ingredient in recipe.outputs:
		var slot = INGREDIENT_SLOT_SCENE.instantiate()
		output_items_list.add_child(slot)
		slot.display_item(output_ingredient.item, output_ingredient.quantity)
	# --- FIN DE LA NOUVELLE LOGIQUE ---
	
	# La logique pour les ingrédients en entrée ne change pas
	for child in ingredients_list.get_children():
		child.queue_free()
	
	for ingredient_data in recipe.ingredients:
		var slot = INGREDIENT_SLOT_SCENE.instantiate()
		ingredients_list.add_child(slot)
		slot.display_ingredient_info(ingredient_data.item, ingredient_data.quantity)

	craft_button.disabled = not CraftingManager.can_craft(recipe)

# --- Fonctions des Boutons ---
func _on_craft_button_pressed():
	if CraftingManager.craft(current_recipe):
		# Si le craft réussit, on met à jour l'affichage
		# pour refléter les nouvelles quantités d'ingrédients
		show_recipe_details(current_recipe)

func _on_close_button_pressed():
	visible = false # On cache simplement la fenêtre
