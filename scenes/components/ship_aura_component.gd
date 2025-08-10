class_name ShipAuraComponent
extends EffectSource2D



func _ready() -> void:
	EnvironmentManager.register(self)
	print("Aura enregistrée :", self, "  sources =", EnvironmentManager._sources.size())

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		EnvironmentManager.unregister(self)


#func _draw():
	#draw_circle(Vector2.ZERO, effect_radius, Color(1,0,0,0.25))
