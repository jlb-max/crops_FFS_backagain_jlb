class_name LightEffectData
extends Resource

@export var has_light_effect: bool = false

@export_group("Émission de Lumière")
@export var light_emission: float = 0.0 # Intensité de la lumière
@export var light_color: Color = Color("ffff7d") # Couleur de la lumière

@export_group("Sensibilité à la Lumière")
# > 0 aime la lumière, < 0 n'aime pas, 0 = neutre
@export_range(-1.0, 1.0) var light_sensitivity: float = 0.0 

@export_group("Animation (Shimmer)")
@export var shimmer_duration: float = 2.5
# Énergie min/max en pourcentage de la base (ex: 0.6 = 60%)
@export_range(0.0, 1.0) var shimmer_min_factor: float = 0.8
@export_range(1.0, 2.0) var shimmer_max_factor: float = 1.2
