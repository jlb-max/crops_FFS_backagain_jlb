# monolithe_ancien.gd
extends StaticBody2D # Ou le type de votre noeud racine

# --- Références aux Nœuds ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var reward_machine_component: RewardMachineComponent = $RewardMachineComponent
@onready var aura: ShipAuraComponent = $Aura


# --- Variables ---
var _player_is_nearby: bool = false

# --- Fonctions de Godot ---
func _ready():
	# On connecte les signaux de proximité
	interactable_component.body_entered.connect(_on_body_entered)
	interactable_component.body_exited.connect(_on_body_exited)
	
	# On désactive l'écoute des touches par défaut pour optimiser
	set_process_input(false)
	interactable_label_component.hide()

func _input(event: InputEvent):
	# Si le joueur appuie sur la touche d'interaction...
	if Input.is_action_just_pressed("show_dialogue"):
		# ...on ouvre le menu de la machine à récompenses
		GameManager.open_reward_machine_menu(reward_machine_component)

# --- Fonctions connectées aux signaux ---
func _on_body_entered(body: Node2D):
	if body is Player:
		_player_is_nearby = true
		set_process_input(true)
		interactable_label_component.show()

func _on_body_exited(body: Node2D):
	if body is Player:
		_player_is_nearby = false
		set_process_input(false)
		interactable_label_component.hide()
