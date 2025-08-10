extends HBoxContainer

signal recipe_selected(recipe)

@onready var input_items_container: HBoxContainer = $InputItemsContainer
@onready var output_items_container: HBoxContainer = $OutputItemsContainer


@onready var convert_button: Button = $ConvertButton
@onready var progress_bar: ProgressBar = $ProgressBar

var current_recipe: MachineRecipe
var machine_component_ref: ProcessingMachineComponent

func _ready():
	convert_button.pressed.connect(_on_convert_button_pressed)

# La fonction est maintenant plus complexe
func display_recipe(recipe: MachineRecipe, machine: ProcessingMachineComponent):
	current_recipe = recipe
	machine_component_ref = machine
	
	# Vider les anciens slots
	for child in input_items_container.get_children():
		child.queue_free()
	for child in output_items_container.get_children():
		child.queue_free()

	# Remplir avec les nouveaux inputs
	for input_ingredient in recipe.inputs:
		var slot = preload("res://scenes/ui/inventoryslot.tscn").instantiate() # Précharger la scène du slot
		input_items_container.add_child(slot)
		slot.display_item(input_ingredient.item, input_ingredient.quantity)
		
	# Remplir avec les nouveaux outputs
	for output_ingredient in recipe.outputs:
		var slot = preload("res://scenes/ui/inventoryslot.tscn").instantiate() # Précharger la scène du slot
		output_items_container.add_child(slot)
		slot.display_item(output_ingredient.item, output_ingredient.quantity)

	# On vérifie si la machine est en train de traiter CETTE recette spécifique
	if machine.current_state == ProcessingMachineComponent.State.PROCESSING and machine.current_recipe_processing == recipe:
		convert_button.visible = false
		progress_bar.visible = true
		machine.progress_updated.connect(progress_bar.set_value)
	else:
		# Sinon (machine inactive OU occupée avec une AUTRE recette)
		progress_bar.visible = false
		convert_button.visible = true
		
		# On vérifie si le joueur a TOUS les ingrédients pour cette recette
		var can_process = true
		for ingredient in recipe.inputs:
			if InventoryManager.get_item_count(ingredient.item) < ingredient.quantity:
				can_process = false
				break
		
		# On désactive le bouton si on ne peut pas la crafter OU si la machine est déjà occupée
		convert_button.disabled = not can_process or machine.current_state != ProcessingMachineComponent.State.IDLE

func _on_convert_button_pressed():
	recipe_selected.emit(current_recipe)
