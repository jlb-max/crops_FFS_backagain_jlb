# oxygen_effect_data.gd
class_name OxygenEffectData
extends Resource

@export var emits_oxygen     : bool  = false      # La plante produit-elle de l’O₂ ?
@export var oxygen_power     : float = 1.0        # Intensité du buff (+) ou du malus (–)
@export var oxygen_radius    : float = 64.0       # Portée en pixels
@export_range(-1.0, 1.0) var oxygen_sensitivity : float = 0.0
#  >0  ⇒ la plante pousse mieux avec O₂ ;  <0 ⇒ la plante n’aime pas l’oxygène
