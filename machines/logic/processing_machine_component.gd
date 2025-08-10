# processing_machine_component.gd
class_name ProcessingMachineComponent
extends Node

# Signal émis quand l'état de la machine change
signal state_changed(new_state)
signal progress_updated(progress_percentage)
enum State { IDLE, PROCESSING, FINISHED }

# La liste des recettes que CETTE machine accepte
@export var accepted_recipes: Array[MachineRecipe]

@export var machine_type: StringName


var current_state: State = State.IDLE
var output_buffer = null # Contiendra { "item": ItemData, "quantity": int }
var current_recipe_processing: MachineRecipe = null

@onready var timer: Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_processing_finished)
	set_state(State.IDLE)
	set_process(false)

func _process(delta):
	if current_state == State.PROCESSING and timer.wait_time > 0:
		var time_left = timer.time_left
		var total_time = timer.wait_time
		var percentage = (1.0 - (time_left / total_time)) * 100.0
		progress_updated.emit(percentage)

# Fonction principale pour démarrer le processus
func start_processing(recipe_to_process: MachineRecipe) -> bool:
	if current_state != State.IDLE: return false
	
	# 1. On vérifie si on a tous les ingrédients
	for ingredient in recipe_to_process.inputs:
		if InventoryManager.get_item_count(ingredient.item) < ingredient.quantity:
			return false # On s'arrête si un seul ingrédient manque

	# 2. Si tout est bon, on consomme tous les ingrédients
	for ingredient in recipe_to_process.inputs:
		InventoryManager.remove_item(ingredient.item, ingredient.quantity)
	
	# Le reste de la fonction est presque identique...
	output_buffer = recipe_to_process.outputs # Le buffer contient maintenant le tableau de sorties
	current_recipe_processing = recipe_to_process
	timer.start(recipe_to_process.processing_time_seconds)
	
	set_state(State.PROCESSING)
	set_process(true)
	return true

# Quand le timer est fini
func _on_processing_finished():
	set_state(State.FINISHED)
	set_process(false)

# Quand le joueur récupère le produit
func collect_output():
	if current_state != State.FINISHED: return

	# On ajoute chaque objet de la sortie à l'inventaire
	for item_out in output_buffer:
		InventoryManager.add_item(item_out.item, item_out.quantity)
		print("Récupéré %d x %s" % [item_out.quantity, item_out.item.item_name])
	
	output_buffer = null
	current_recipe_processing = null
	set_state(State.IDLE)
	set_process(false)

func set_state(new_state: State):
	current_state = new_state
	state_changed.emit(current_state)
