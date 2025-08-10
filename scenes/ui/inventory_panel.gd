# inventory_panel.gd (nouvelle version)
extends PanelContainer

@export var recipe_detail_window: PanelContainer

@onready var grid_container: GridContainer = $TabContainer/Inventaire/GridContainer
var inventory_slot_scene = preload("res://scenes/ui/inventoryslot.tscn") # Adaptez le chemin

func _ready() -> void:
	# On pré-remplit la grille avec des slots vides
	for i in range(InventoryManager.inventory_size):
		var slot = inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.display_empty()

	InventoryManager.inventory_changed.connect(redraw_inventory)
	# On cache l'inventaire au démarrage
	visible = false
	$TabContainer/Artisanat.recipe_detail_window = recipe_detail_window

# Fonction pour afficher/cacher l'inventaire
func _unhandled_input(event: InputEvent) -> void:
	# On interroge l'objet global "Input" au lieu de la variable "event"
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = not visible

# Fonction pour redessiner le contenu de l'inventaire
func redraw_inventory() -> void:
	for i in range(InventoryManager.slots.size()):
		var slot_node = grid_container.get_child(i)
		var slot_data = InventoryManager.slots[i]
		
		slot_node.slot_index = i

		if slot_data != null:
			slot_node.display_item(slot_data.item, slot_data.quantity)
		else:
			slot_node.display_empty()
