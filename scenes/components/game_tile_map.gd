extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grass := get_node_or_null("Grass")
	if grass == null:
		push_error("[EffectMaps] Grass introuvable depuis GameTileMap")
	else:
		EffectMaps.register_terrain_layer(grass)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
