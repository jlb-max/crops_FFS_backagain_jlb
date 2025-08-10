# test_scene_enable_tool_buttons_component.gd (Nouvelle Version)
extends Node

func _ready() -> void:
	# On attend un instant pour être sûr que l'inventaire est prêt
	call_deferred("give_test_items")

func give_test_items() -> void:
	print("DEBUG: Le composant de test donne les items de départ au joueur.")

	# On charge les ressources des items que l'on veut donner pour le test
	var hoe_item = load("res://scenes/objects/hoe.tres")
	var axe_item = load("res://scenes/objects/axe.tres")
	var watering_can_item = load("res://scenes/objects/watering_can.tres")
	var corn_seed_item = load("res://scenes/objects/plants/corn_seed.tres")

	# On ajoute ces items à l'inventaire.
	# Le ToolsPanel va automatiquement se mettre à jour grâce au signal "inventory_changed".
	InventoryManager.add_item(hoe_item, 1)
	InventoryManager.add_item(axe_item, 1)
	InventoryManager.add_item(watering_can_item, 1)
	InventoryManager.add_item(corn_seed_item, 10) # On donne 10 graines pour tester
