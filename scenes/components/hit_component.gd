# hit_component.gd (mis à jour)
class_name HitComponent
extends Area2D

# On supprime la variable "current_tool", elle est obsolète.

# Cette fonction peut être appelée par les états du joueur pour activer la "hitbox"
func enable_hitbox() -> void:
	$CollisionShape2D.disabled = false

func disable_hitbox() -> void:
	$CollisionShape2D.disabled = true
