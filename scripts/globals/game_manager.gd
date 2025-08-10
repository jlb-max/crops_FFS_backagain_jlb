#gamemanager.gd (autoload)
extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")

var biofuel_menu
var reward_machine_menu
var heater_fuel_menu
var dna_analyzer_menu

const FADE_OUT  : float = 0.2      # noir rapide
const FADE_IN   : float = 2.0      # retour en douceur
const FAINT_DELAY : float = 3.0


@onready var _screen_fade := get_tree().get_first_node_in_group("screen_fade")
@onready var _player         := get_tree().get_first_node_in_group("player")
@onready var _player_status  := get_tree().get_first_node_in_group("player_status")
@onready var _ship_anchor    := get_tree().get_first_node_in_group("ship_anchor") # Node2D


func _ready() -> void:
	if _player_status:
		_player_status.player_fainted.connect(_on_player_fainted)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		show_game_menu_screen()

func _on_player_fainted() -> void:
	_player.set_process_input(false)           # plus de contrôle

	## 1) petit délai avant le black-out  ──────────────────────────
	await get_tree().create_timer(FAINT_DELAY).timeout

	## 2) FADE-OUT (écran noir rapide)  ────────────────────────────
	_do_fade(1.0)                              # 1 = opaque
	await get_tree().create_timer(FADE_OUT).timeout

	## 3) Téléportation + rétablissement partiel  ─────────────────
	if _ship_anchor:
		_player.global_position = _ship_anchor.global_position + Vector2(0, -16)

	var ps := _player_status
	ps.health       = ps.max_health  * 0.25
	ps.oxygen       = ps.max_oxygen  * 0.25
	ps.body_temp    = ps.max_heat    * 0.25
	ps.grav_balance = ps.max_gravity * 0.25
	ps.status_changed.emit(ps.health, ps.oxygen, ps.body_temp, ps.grav_balance)

	## 4) FADE-IN (retour tout doux)  ──────────────────────────────
	_do_fade(0.0)                              # 0 = transparent
	await get_tree().create_timer(FADE_IN).timeout

	_player.set_process_input(true)


func _do_fade(target_alpha: float) -> void:
	if not _screen_fade: return
	var dur := FADE_OUT if target_alpha > 0.5 else FADE_IN   # choix auto
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_screen_fade, "modulate:a", target_alpha, dur)

func register_dna_analyzer_menu(menu_node):
	dna_analyzer_menu = menu_node
	
func open_dna_analyzer_menu(machine_node):
	if dna_analyzer_menu:
		dna_analyzer_menu.open_menu(machine_node)

func register_biofuel_menu(menu_node):
	biofuel_menu = menu_node

func register_reward_machine_menu(menu_node):
	reward_machine_menu = menu_node

func open_reward_machine_menu(machine_component: RewardMachineComponent):
	if reward_machine_menu:
		reward_machine_menu.open_menu(machine_component)

func open_biofuel_menu(machine_component: ProcessingMachineComponent):
	if biofuel_menu:
		biofuel_menu.open_menu(machine_component)

func register_heater_fuel_menu(menu_node): # <--- 2. AJOUTER CETTE FONCTION
	heater_fuel_menu = menu_node

func open_heater_menu(machine_node: Node): # <--- 3. AJOUTER CETTE FONCTION
	if heater_fuel_menu:
		heater_fuel_menu.open_menu(machine_node)

func start_game() -> void:
	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1") 
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true

func exit_game() -> void:
	get_tree().quit()

func show_game_menu_screen() -> void:
	var game_menu_screen_instance = game_menu_screen.instantiate()
	get_tree().root.add_child(game_menu_screen_instance)
