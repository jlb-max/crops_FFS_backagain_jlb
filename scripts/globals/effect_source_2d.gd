class_name EffectSource2D
extends Area2D
## Classe-mère minimale : un rayon + 3 puissances

@export var effect_radius  : float = 64.0      # px
@export var heat_power     : float = 0.0       # + = chauffe ; – = refroidit
@export var oxygen_power   : float = 0.0       # idem pour O₂   (sera utile)
@export var gravity_power  : float = 0.0       # + = stabilise, – = perturbe
