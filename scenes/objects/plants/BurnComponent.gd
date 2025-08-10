class_name BurnComponent
extends Area2D

@export var burn_power : float = 1.0      # dégâts/s
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
var _victims : Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(func(b): if b.is_in_group("crops"): _victims.append(b))
	body_exited .connect(func(b): _victims.erase(b))

func _process(delta):
	for v in _victims:
		if v.has_method("take_damage"):
			v.take_damage(burn_power * delta)
