#game_screen.gd
extends CanvasLayer



@onready var gauge_hp: HBoxContainer = $HUDContainer/HBox/GaugeHealth
@onready var gauge_o2: HBoxContainer = $HUDContainer/HBox/GaugeOxygen
@onready var gauge_tmp: HBoxContainer = $HUDContainer/HBox/GaugeHeat
@onready var gauge_grv: HBoxContainer = $HUDContainer/HBox/GaugeGravity
@onready var codex_screen: HSplitContainer = $CodexScreen

@onready var effects_overlay: EffectsOverlay    = $"../GameTileMap/EffectsOverlay"
@onready var effects_toolbar: PanelContainer    = $HUDContainer/EffectsToolbar



var player_status : PlayerStatusComponent


func _unhandled_input(event: InputEvent) -> void:
	# CODex (inchangé)
	if Input.is_action_just_pressed("toggle_codex"):
		get_viewport().set_input_as_handled()
		codex_screen.visible = not codex_screen.visible
		if codex_screen.visible:
			codex_screen.refresh_display()
		return

	# Carte d'effets (M)
	if Input.is_action_just_pressed("toggle_overlay_map"):
		get_viewport().set_input_as_handled()
		if effects_overlay:
			var new_vis := not effects_overlay.overlay_visible
			effects_overlay.set_overlay_visible(new_vis)
			if effects_toolbar:
				effects_toolbar.visible = new_vis
		return

func _ready() -> void:
	# 1. récupère le composant dans le groupe
	player_status = get_tree().get_first_node_in_group("player_status") \
					as PlayerStatusComponent
	if player_status:
		player_status.status_changed.connect(_on_status)
		
	if effects_toolbar:
		effects_toolbar.visible = false

func _on_status(h, o2, t, g) -> void:
	gauge_hp.set_ratio(h / player_status.max_health)
	gauge_o2.set_ratio(o2 / player_status.max_oxygen)
	gauge_tmp.set_ratio(t / player_status.max_heat)
	gauge_grv.set_ratio(g / player_status.max_gravity)

func _toggle_effects_overlay() -> void:
	if effects_overlay:
		var new_vis := not effects_overlay.overlay_visible
		effects_overlay.set_overlay_visible(new_vis)
		if effects_toolbar:
			effects_toolbar.visible = new_vis
