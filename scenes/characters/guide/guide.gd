extends Node2D

var balloon_scene = preload("res://dialogue/game_dialogue_balloon.tscn")

@export_group("Items à Donner")
@export var hoe_item: ItemData
@export var watering_can_item: ItemData
@export var corn_seed_item: ItemData
@export var tomato_seed_item: ItemData
@export var axe_item: ItemData


@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent

var in_range: bool


func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()
	
	GameDialogueManager.give_crop_seeds.connect(on_give_crop_seeds)


func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true


func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false


func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialogue/conversations/guide.dialogue"), "start")


func on_give_crop_seeds() -> void:
	# On appelle la bonne fonction avec les bonnes ressources
	InventoryManager.add_item(hoe_item, 1)
	InventoryManager.add_item(watering_can_item, 1)
	InventoryManager.add_item(corn_seed_item, 3)
	InventoryManager.add_item(tomato_seed_item, 3)
	InventoryManager.add_item(axe_item, 1)
		
	print("Le guide a donné les outils de base et des graines au joueur !")
