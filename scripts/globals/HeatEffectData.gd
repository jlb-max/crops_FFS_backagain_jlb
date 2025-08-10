# HeatEffectData.gd
class_name HeatEffectData
extends Resource

# Est-ce que cette plante émet de la chaleur ?
@export var emits_heat: bool = false
# Si oui, sa puissance et son rayon
@export var heat_power: float = 1.0
@export var heat_radius: float = 64.0
# La capacité à brûler les plantes adjacentes (0 = ne brûle pas)
@export var burn_power: float = 0.0
# Comment cette plante réagit à la chaleur ambiante
@export_range(-1.0, 1.0) var heat_sensitivity: float = 0.0 # >0 aime, <0 n'aime pas
