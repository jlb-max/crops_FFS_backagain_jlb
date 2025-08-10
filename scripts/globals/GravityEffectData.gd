# GravityEffectData.gd
class_name GravityEffectData
extends Resource

@export var has_gravity_effect: bool = false
@export var gravity_influence: float = 0.0
@export var gravity_radius: float = 64.0
# Comment cette plante réagit à la gravité ambiante
@export_range(-1.0, 1.0) var gravity_sensitivity: float = 0.0

@export_group("Animation des Vagues")
@export var wave_amplitude: float = 6.0
@export var wave_wavelength: float = 32.0
@export var wave_speed: float = 2.0
