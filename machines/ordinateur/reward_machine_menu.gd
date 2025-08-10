# reward_machine_menu.gd (Version corrigée et dynamique)
extends PanelContainer

# --- Références Mises à Jour ---
@onready var title_label: Label = $VBoxContainer/Label
@onready var requirements_container: VBoxContainer = $VBoxContainer/RequirementsContainer # Le nouveau VBox
@onready var close_button: Button = $VBoxContainer/CloseButton

# On précharge VOTRE scène de slot existante
var inventory_slot_scene = preload("res://scenes/ui/inventoryslot.tscn") # <-- Adaptez ce chemin !
var machine: RewardMachineComponent

func _ready():
	GameManager.register_reward_machine_menu(self)
	close_button.pressed.connect(close_menu)
	hide()

func open_menu(machine_component: RewardMachineComponent):
	machine = machine_component
	if not machine.progress_updated.is_connected(update_display):
		machine.progress_updated.connect(update_display)
	update_display()
	show()

# Dans reward_machine_menu.gd

func update_display(progress_data = null, requirements_data = null):
	if not is_instance_valid(machine): return

	# On nettoie les anciens slots
	for child in requirements_container.get_children():
		child.queue_free()

	var requirements = machine.get_current_requirements()
	var progress = machine.progress_per_item

	if requirements.is_empty():
		title_label.text = "Tous les objectifs sont atteints !"
		return

	title_label.text = "Objectifs Actuels :"

	# On crée un InventorySlot pour chaque ingrédient requis
	for ingredient in requirements:
		var slot = inventory_slot_scene.instantiate() as Panel
		
		# --- CORRECTION DE LA LOGIQUE ---
		# 1. On AJOUTE d'abord le slot à la scène. C'est ce qui initialise ses @onready.
		requirements_container.add_child(slot)
		
		# 2. ENSUITE, on appelle ses fonctions de configuration.
		var submitted_qty = progress.get(ingredient.item, 0)
		slot.display_ingredient_info(ingredient.item, ingredient.quantity)
		
		# 3. On ajuste le texte (comme avant)
		var possessed_qty = InventoryManager.get_item_count(ingredient.item)
		slot.label.text = "%d/%d (Vous avez %d)" % [submitted_qty, ingredient.quantity, possessed_qty]

		# 4. On connecte le signal pour le clic
		slot.gui_input.connect(_on_slot_clicked.bind(slot))

# Nouvelle fonction pour gérer le clic
func _on_slot_clicked(event: InputEvent, slot: Panel):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# On ajoute 1 unité de l'item contenu dans le slot cliqué
		machine.add_item(slot.item_data, 1)

func close_menu():
	if is_instance_valid(machine) and machine.progress_updated.is_connected(update_display):
		machine.progress_updated.disconnect(update_display)
	hide()
