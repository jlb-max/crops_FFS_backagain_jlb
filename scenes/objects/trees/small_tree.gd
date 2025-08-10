extends AnimatedSprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent
@export var log_item_to_drop: ItemData

var log_scene = preload("res://scenes/objects/trees/log.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)


func on_hurt(item_used: ItemData) -> void:
	damage_component.apply_damage(item_used.damage)
	material.set_shader_parameter("shake_intensity", 0.5)
	await get_tree().create_timer(1.0).timeout
	material.set_shader_parameter("shake_intensity", 0.0)

func on_max_damage_reached() -> void:
	call_deferred("add_log_scene")
	print("max damaged reached")
	queue_free()

func add_log_scene() -> void:
	var log_instance = log_scene.instantiate()
	get_parent().add_child(log_instance)
	log_instance.global_position = global_position
	
	# --- LIGNES CLÉS À AJOUTER ---
	# 1. On récupère le CollectableComponent sur la nouvelle instance de rondin
	var collectable = log_instance.get_node("CollectableComponent")

	# 2. On lui assigne les données de l'item que l'arbre doit laisser tomber
	if collectable and log_item_to_drop:
		collectable.item_data = log_item_to_drop
	else:
		print("ERREUR: Le CollectableComponent ou le 'log_item_to_drop' n'est pas configuré sur l'arbre.")
