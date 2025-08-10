# --------------------------------------------------------------------------
#  PlayerStatusComponent.gd
#  Gère les jauges vitales du joueur et émet un signal à chaque variation
# --------------------------------------------------------------------------
class_name PlayerStatusComponent
extends Node


const DEBUG_STATUS : bool = false

@export var invincible_pour_tests: bool = false
# — valeurs limites —
@export var max_health  : int   = 100
@export var max_oxygen  : int   = 100
@export var max_heat    : int   = 100      # température corporelle
@export var max_gravity : int   = 100      # équilibre gravitationnel

# — valeurs courantes —
var health       : float = max_health
var oxygen       : float = max_oxygen
var body_temp    : float = max_heat
var grav_balance : float = max_gravity

# facteurs de perte par seconde quand rien n’est fourni
const OXYGEN_DECAY : float =  5.0   # /s
const HEAT_DECAY   : float =  4.0   # /s
const GRAV_DECAY   : float =  3.0   # /s
const DAMAGE_RATE  : float = 10.0   # HP/s quand une jauge est à zéro

signal status_changed(health, oxygen, body_temp, grav_balance)
signal player_fainted

func _process(delta: float) -> void:
	if invincible_pour_tests:
		return
	# 0. Effets cumulés de l’environnement
	var eff := EnvironmentManager.get_local_effects(get_parent().global_position)
	#print("heat=", eff.heat, "  distance=",
	  #get_parent().global_position.distance_to(EnvironmentManager._sources[0].global_position))
	# eff = { heat: float, oxygen: float, gravity: float }

	# 1. Applique gains / pertes
	oxygen       = clamp(oxygen    + eff.oxygen  * delta - OXYGEN_DECAY * delta, 0, max_oxygen)
	body_temp    = clamp(body_temp + eff.heat    * delta - HEAT_DECAY   * delta, 0, max_heat)
	if DEBUG_STATUS:
		print("body_temp =", body_temp, " eff.heat =", eff.heat)
	grav_balance = clamp(grav_balance + eff.gravity * delta - GRAV_DECAY * delta, 0, max_gravity)

	# 2. Dégâts en cas de carence
	var harmed := false
	if oxygen == 0 or body_temp == 0:
		health = clamp(health - DAMAGE_RATE * delta, 0, max_health)
		harmed = true

	# 3. Émission de signaux (UI + mort éventuelle)
	status_changed.emit(health, oxygen, body_temp, grav_balance)

	if health == 0 and harmed and GameConfig.ENABLE_FAINTING:
		player_fainted.emit()          # ← on laisse le GameManager gérer
		# bloque la boucle : on ne spamme pas
		health = 0.1  
