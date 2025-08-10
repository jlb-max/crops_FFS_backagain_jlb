# res://scenes/objects/plants/auracomponent.gd
class_name AuraComponent
extends EffectSource2D




var heat_data   : HeatEffectData
var grav_data   : GravityEffectData
var oxygen_data : OxygenEffectData      # (tu l’ajouteras juste après)
var _registered := false

func _ready() -> void:
	if not _registered:
		EnvironmentManager.register(self)
		_registered = true

func init(
		heat : HeatEffectData     = null,
		grav : GravityEffectData  = null,
		oxy  : OxygenEffectData   = null) -> void:

	heat_data   = heat
	grav_data   = grav
	oxygen_data = oxy

	# 1) Rayon -----------------------------------------------------------
	effect_radius  = 0.0
	if heat_data   and heat_data.emits_heat:
		effect_radius = max(effect_radius, heat_data.heat_radius)
	if grav_data   and grav_data.has_gravity_effect:
		effect_radius = max(effect_radius, grav_data.gravity_radius)
	if oxygen_data and oxygen_data.emits_oxygen:
		effect_radius = max(effect_radius, oxygen_data.oxygen_radius)

	# 2) Puissances ------------------------------------------------------
	heat_power    = heat_data.heat_power           if heat_data   else 0.0
	gravity_power = grav_data.gravity_influence    if grav_data   else 0.0
	oxygen_power  = oxygen_data.oxygen_power       if oxygen_data else 0.0

	# 3) Collider (facultatif) ------------------------------------------
	monitoring    = false        # on ne surveille personne ici
	monitorable   = false
	$CollisionShape2D.shape.radius = effect_radius
	$CollisionShape2D.disabled     = true          # pure aura
	

	if not _registered:
		EnvironmentManager.register(self)
		_registered = true

func _exit_tree() -> void:
	if _registered:
		EnvironmentManager.unregister(self)
		_registered = false

func _draw():
	draw_circle(Vector2.ZERO, effect_radius, Color(1,0,0,0.25))
