extends StaticBody2D


#@onready var sprite_anim: AnimatedSprite2D = $SpriteAnim
@onready var sprite_anim: AnimatedSprite2D = $SpriteAnim

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var processing_component: ProcessingMachineComponent = $ProcessingMachineComponent
@onready var output_indicator: Sprite2D = $OutputIndicator
@onready var progress_bar: ProgressBar = $ProgressBar

@export var swing_speed: float = 3.0
@export var swing_angle: float = 15.0 # Angle maximum en degrés
@export var pulse_speed: float = 5.0
@export var pulse_amount: float = 0.08

@export var menu_ui: PanelContainer

# Cette variable nous dira si le joueur est assez proche pour interagir
var _player_is_nearby: bool = false

func _ready():
	# --- CORRECTION : On assigne le noeud à la variable ---
	sprite_anim = get_node("SpriteAnim")
	
	# On active l'input une seule fois.
	set_process_input(true)
	
	# On connecte les signaux de nos composants
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)
	processing_component.state_changed.connect(on_state_changed)
	
	# On met à jour l'état initial
	on_state_changed(processing_component.current_state)
	
	if interactable_label_component:
		interactable_label_component.hide()

# Cette fonction est appelée quand le joueur entre dans la zone
func _on_body_entered(body: Node2D):
	# On vérifie si c'est bien le joueur
	if body is Player:
		_player_is_nearby = true
		set_process_input(true)
		interactable_label_component.show()

# Cette fonction est appelée quand le joueur sort de la zone
func _on_body_exited(body: Node2D):
	# On vérifie si c'est bien le joueur
	if body is Player:
		_player_is_nearby = false
		set_process_input(false)
		interactable_label_component.hide()

# Cette fonction ne s'exécute que lorsque le joueur est dans la zone
func _input(event: InputEvent):
	# Si le joueur n'est pas à côté, on ne fait absolument rien.
	if not _player_is_nearby:
		return

	# Si le joueur EST à côté, alors on écoute la touche d'action.
	if Input.is_action_just_pressed("show_dialogue"):
		on_interacted()

# C'est ici que se trouve la logique de la machine
func on_interacted():
	print("Interaction ! État actuel de la machine : ", ProcessingMachineComponent.State.keys()[processing_component.current_state])
	# Si la machine est inactive, on demande au GameManager d'ouvrir le menu
	if processing_component.current_state == ProcessingMachineComponent.State.IDLE:
		GameManager.open_biofuel_menu(processing_component)

	# La logique pour récupérer un objet terminé ne change pas
	elif processing_component.current_state == ProcessingMachineComponent.State.FINISHED:
		var collected_item = processing_component.collect_output()
		if collected_item:
			print("Récupéré %d x %s" % [collected_item.quantity, collected_item.item.item_name])

# Cette fonction gère le visuel de la machine et ne change pas
func on_state_changed(new_state):
	match new_state:
		ProcessingMachineComponent.State.IDLE:
			sprite_anim.modulate = Color.WHITE
			output_indicator.visible = false
			progress_bar.visible = false # Cacher la barre
			
			# MODIFICATION 2 : Lancer l'animation "off"
			sprite_anim.play("off")
		
		ProcessingMachineComponent.State.PROCESSING:
			sprite_anim.modulate = Color(0.8, 0.8, 1.0)
			output_indicator.visible = false
			progress_bar.visible = true # Afficher la barre
			
			# MODIFICATION 3 : Lancer l'animation "on"
			sprite_anim.play("on")
			
		ProcessingMachineComponent.State.FINISHED:
			sprite_anim.modulate = Color.WHITE
			progress_bar.visible = false # Cacher la barre
			
			# MODIFICATION 4 : Lancer l'animation "off"
			sprite_anim.play("off")
			
			# Le reste de la logique pour l'indicateur de sortie ne change pas
			if not processing_component.output_buffer.is_empty():
				output_indicator.visible = true
				var first_output_item = processing_component.output_buffer[0].item
				output_indicator.texture = first_output_item.icon


func _process(delta: float):
	if output_indicator.visible:
		# On calcule le nouvel angle en utilisant le sinus du temps
		var time = Time.get_ticks_msec() / 1000.0 # Temps en secondes
		var new_angle = sin(time * swing_speed) * swing_angle
		output_indicator.rotation_degrees = new_angle
	
	# On met à jour la barre uniquement si la machine travaille
	if processing_component.current_state == ProcessingMachineComponent.State.PROCESSING:
		# On calcule le progrès en se basant sur le temps restant du timer
		var time_left = processing_component.timer.time_left
		var total_time = processing_component.timer.wait_time
		progress_bar.value = (1.0 - (time_left / total_time)) * 100.0
	else:
		# Sinon, on s'assure qu'elle est cachée
		progress_bar.visible = false


func _on_interactable_activated():
	_player_is_nearby = true
	if interactable_label_component:
		interactable_label_component.show()


func _on_interactable_deactivated():
	_player_is_nearby = false
	if interactable_label_component:
		interactable_label_component.hide()
