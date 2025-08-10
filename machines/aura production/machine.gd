# scripts/machines/Machine.gd
@tool
class_name Machine
extends Area2D

## Ressource de carburant acceptée par la machine
@export var biofuel_item: Resource # Fais glisser ton BiofuelItem.tres ici

## Consommation toutes les X secondes
@export var consumption_interval: float = 10.0
@export var is_on: bool = false:
	set(value):
		is_on = value
		update_machine_state()

# Le "slot d'inventaire" de la machine
var current_biofuel: int = 0
@export var max_biofuel: int = 5

@export var heat_effect_data: HeatEffectData
@export var oxygen_effect_data: OxygenEffectData
@export var gravity_effect_data: GravityEffectData

@onready var consumption_timer: Timer = $ConsumptionTimer
@onready var aura_component: AuraComponent = $AuraComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	consumption_timer.wait_time = consumption_interval
	consumption_timer.one_shot = false # Le timer tournera en boucle
	consumption_timer.connect("timeout", _on_consumption_timer_timeout)
	update_machine_state()

func update_machine_state() -> void:
	if is_on and current_biofuel > 0:
		consumption_timer.start()
		animated_sprite.play("on")
		# On active l'aura en l'initialisant avec les données
		aura_component.init(heat_effect_data, gravity_effect_data, oxygen_effect_data)
	else:
		is_on = false
		consumption_timer.stop()
		animated_sprite.play("off")
		# On désactive l'aura en l'initialisant avec "null" (aucune donnée)
		aura_component.init(null, null, null)

func _on_consumption_timer_timeout() -> void:
	current_biofuel -= 1
	print("Biofuel consommé. Restant : %d" % current_biofuel)
	if current_biofuel <= 0:
		update_machine_state()

## Logique à appeler quand le joueur interagit (ex: via input) pour ajouter du carburant
func add_fuel(player_inventory) -> void:
	# Note: La logique exacte dépend de ton script d'inventaire
	# Ici, on suppose que le joueur a un inventaire et qu'on peut y retirer un item.
	if player_inventory.has_item(biofuel_item):
		if current_biofuel < max_biofuel:
			player_inventory.remove_item(biofuel_item)
			current_biofuel += 1
			print("Carburant ajouté. Total : %d" % current_biofuel)
			# Si la machine était éteinte par manque de fuel, on la relance
			if not is_on:
				is_on = true
