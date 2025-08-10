# DNAAnalyzer.gd (Version corrigée)
extends StaticBody2D

# Références aux composants d'interaction
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var progress_bar: ProgressBar = $ProgressBar # Assurez-vous que le chemin est bon
@onready var timer: Timer = $Timer # Le nouveau Timer
@onready var sprite_anim: AnimatedSprite2D = $SpriteAnim


@export var sequencing_time: float = 5.0 # Temps en secondes pour une analyse
var is_sequencing: bool = false
var item_being_sequenced: ItemData = null

# Variable pour suivre la présence du joueur
var _player_is_nearby: bool = false

func _ready():
	set_process_input(true)
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)
	timer.timeout.connect(_on_sequencing_finished) # On connecte le signal du timer
	
	progress_bar.visible = false # On cache la barre au début
	set_process(false) # Pas besoin de process au début
	
	# On s'assure que le label est bien caché au démarrage
	if interactable_label_component:
		interactable_label_component.hide()

func _process(delta: float):
	# On met à jour la barre de progression en fonction du temps restant
	if is_sequencing and timer:
		progress_bar.value = sequencing_time - timer.time_left


func _input(event: InputEvent):
	if not _player_is_nearby:
		return
	if Input.is_action_just_pressed("show_dialogue"):
		on_interacted()

func on_interacted():
	# Si la machine est déjà en train de travailler, on n'ouvre pas le menu
	if is_sequencing:
		print("Séquenceur déjà en cours d'utilisation.")
		return
	GameManager.open_dna_analyzer_menu(self)

func start_sequencing(item: ItemData):
	if is_sequencing: return

	print("Lancement du séquençage pour : ", item.item_name)
	is_sequencing = true
	item_being_sequenced = item
	
	progress_bar.max_value = sequencing_time
	progress_bar.value = 0
	progress_bar.visible = true
	
	timer.wait_time = sequencing_time
	timer.start()
	sprite_anim.play("on")
	
	
	set_process(true) # On active _process pour mettre à jour la barre

func _on_sequencing_finished():
	# --- SÉCURITÉ AJOUTÉE ---
	# Si on n'est pas en train de séquencer, on ne fait rien.
	# Cela évite les exécutions multiples accidentelles.
	if not is_sequencing:
		return

	print("Séquençage de '%s' terminé !" % item_being_sequenced.item_name)
	
	var plant_data = item_being_sequenced.get_source_plant_data()
	if plant_data:
		LoreManager.add_sequencing_progress(plant_data, 1)

	# Réinitialisation
	is_sequencing = false
	item_being_sequenced = null
	progress_bar.visible = false
	set_process(false)
	sprite_anim.play("off")


func _on_interactable_activated():
	_player_is_nearby = true
	if interactable_label_component:
		interactable_label_component.show()

func _on_interactable_deactivated():
	_player_is_nearby = false
	if interactable_label_component:
		interactable_label_component.hide()
