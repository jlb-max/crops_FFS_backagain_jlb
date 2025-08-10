extends Sprite2D

# --- AJOUT 1: Définir l'objet à laisser tomber ---
@export var stone_item_to_drop: ItemData

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent

var stone_scene = preload("res://scenes/objects/rocks/stone.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)

# NOTE : La fonction on_hurt a été mise à jour pour accepter un ItemData
# C'est important pour la cohérence avec le reste du projet.
func on_hurt(item_used: ItemData) -> void:
	# On applique les dégâts définis dans l'outil utilisé
	damage_component.apply_damage(item_used.damage)

	material.set_shader_parameter("shake_intensity", 0.3)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("shake_intensity", 0.0)

func on_max_damage_reached() -> void:
	call_deferred("add_stone_scene")
	queue_free()

func add_stone_scene() -> void:
	var stone_instance = stone_scene.instantiate()
	get_parent().add_child(stone_instance)
	stone_instance.global_position = global_position
	
	# --- AJOUT 2: Configurer l'objet créé ---
	# On récupère le CollectableComponent sur la nouvelle pierre
	var collectable = stone_instance.get_node("CollectableComponent")

	# On lui assigne les données de l'item que le rocher doit laisser tomber
	if collectable and stone_item_to_drop:
		collectable.item_data = stone_item_to_drop
	else:
		print("ERREUR: Le CollectableComponent ou le 'stone_item_to_drop' n'est pas configuré sur le rocher.")
