extends TileMapLayer

func _ready() -> void:
	SoilManager.register_wetness_overlay(self)
