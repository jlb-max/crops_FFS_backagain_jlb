class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated

# On vérifie que le corps qui entre est bien le joueur avant d'émettre le signal
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interactable_activated.emit()

# On fait la même vérification pour la sortie
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		interactable_deactivated.emit()
