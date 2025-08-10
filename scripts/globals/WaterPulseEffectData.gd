# water_pulse_effect_data.gd
@tool
class_name WaterPulseEffectData
extends Resource

@export var has_water_pulse_effect: bool = false

@export_group("Paramètres de l'Onde")
# Le rayon en nombre de tuiles (1 = les 8 tuiles adjacentes)
@export_range(1, 5) var pulse_radius: int = 1
# La durée en secondes pour que la sphère grandisse et éclate
@export var pulse_duration: float = 3.0
