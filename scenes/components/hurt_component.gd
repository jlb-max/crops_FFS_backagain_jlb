# hurt_component.gd (Version finale corrigée et non-destructive)
class_name HurtComponent
extends Area2D

var current_health: float = 100.0

@export var required_action: ItemData.ActionType = ItemData.ActionType.NONE

# On peut même faire en sorte que le signal envoie l'item qui a été utilisé
signal hurt(item_used: ItemData)
signal health_depleted

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# On vérifie si c'est bien la hitbox du joueur
	if area is HitComponent:
		var item_used = ToolManager.get_selected_item()
		
		# Si l'item et son action correspondent à ce qui est requis...
		if item_used and item_used.action_type == required_action:
			print("Objet touché avec le bon outil !")
			
			# Au lieu de détruire, on émet simplement un signal pour prévenir le parent.
			hurt.emit(item_used)


func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		health_depleted.emit()
		get_parent().queue_free() # Par exemple, pour tuer la plante
