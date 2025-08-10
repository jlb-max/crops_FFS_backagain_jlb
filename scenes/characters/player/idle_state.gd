extends NodeState
 
@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:	
	if player.player_direction == Vector2.UP:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("idle_back")
	elif player.player_direction == Vector2.RIGHT:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("idle_right")
	elif player.player_direction == Vector2.DOWN:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("idle_front")
	elif player.player_direction == Vector2.LEFT:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("idle_left")
	else:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("idle_front")


func _on_next_transitions() -> void:
	GameInputEvents.movement_input()
	
	if GameInputEvents.is_movement_input():
		transition.emit("Walk")
		return # On retourne pour ne pas bouger ET utiliser un outil en même temps

	# On vérifie si le joueur veut utiliser un outil
	if GameInputEvents.use_tool():
		# On demande au ToolManager quelle est l'action de l'item en main
		var current_action = ToolManager.get_selected_action()

		# On utilise un "match" pour choisir le bon état de destination
		match current_action:
			ItemData.ActionType.CHOP:
				transition.emit("Chopping")
			ItemData.ActionType.TILL:
				transition.emit("Tilling")
			ItemData.ActionType.WATER:
				transition.emit("Watering")

func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
