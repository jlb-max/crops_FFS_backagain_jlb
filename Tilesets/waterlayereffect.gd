extends Node
@onready var water_layer : TileMapLayer = $"."   # script placé sur le layer Water

func _ready() -> void:
	set_process(true)            # ← indispensable pour que _process() tourne

func _process(delta : float) -> void:
	var mat := water_layer.material as ShaderMaterial
	if mat == null:
		return

	var o : Vector2 = mat.get_shader_parameter("offset") as Vector2
	o.x += delta * 0.2          # vitesse horizontale
	mat.set_shader_parameter("offset", o)
