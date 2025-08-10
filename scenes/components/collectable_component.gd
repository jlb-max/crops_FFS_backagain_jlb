# CollectableComponent.gd (mis à jour)
class_name CollectableComponent
extends Area2D



# On remplace le nom par une référence directe à la ressource ItemData
@export var item_data: CollectibleData


func _ready() -> void:
	# On connecte le signal ici pour être sûr que tout est prêt
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not item_data:
			print("ERREUR: Aucun CollectibleData n'est assigné.")
			return

		# Votre InventoryManager doit pouvoir accepter des CollectibleData
		InventoryManager.add_item(item_data, 1)
		
		get_parent().queue_free()
