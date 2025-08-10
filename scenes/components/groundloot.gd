# GroundLoot.gd
extends Node2D

# La seule variable dont on a besoin. On y glissera notre ressource de graine.
@export var item_data: ItemData

@onready var sprite: Sprite2D = $Sprite2D
@onready var collectable_component: CollectableComponent = $CollectableComponent

func _ready() -> void:
	if not item_data:
		print("ERREUR: GroundLoot n'a pas d'ItemData.")
		queue_free()
		return
	
	# On configure automatiquement les enfants en utilisant les données de l'item
	sprite.texture = item_data.icon
	collectable_component.item_data = item_data
