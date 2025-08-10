extends CanvasLayer     # Autoload « GravityOverlay »

@onready var warp_rect : ColorRect      = $WarpRect
@onready var shader    : ShaderMaterial = warp_rect.material as ShaderMaterial

var _target_node : Node2D  = null
var _radius_px   : float   = 64.0
var _strength    : float   = 0.8

func _ready():
	print("[GravityOverlay] ready, warp_rect =", warp_rect)
	warp_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE   # ne capte pas les clics
	warp_rect.set_anchors_preset(Control.PRESET_FULL_RECT)


# ---------- API publique -------------------------------------------------
func follow(node: Node2D, radius_px: float, strength: float) -> void:
	print("[GravityOverlay] follow appelé par", node.name)
	_target_node = node
	_radius_px   = radius_px
	_strength    = strength
	warp_rect.visible = true

func stop() -> void:
	_target_node = null
	warp_rect.visible = false

func get_warp_rect() -> ColorRect:
	return warp_rect

# ---------- Mise à jour chaque frame ------------------------------------
func _process(_delta: float) -> void:
	if _target_node == null or not is_instance_valid(_target_node):
		stop()
		return

	var cam : Camera2D = get_viewport().get_camera_2d()
	if cam == null:
		return

	# 1. centre UV --------------------------------------------------------
	var screen_pos : Vector2 = cam.get_screen_transform() * _target_node.global_position
	screen_pos -= Vector2(get_viewport().size) * 0.5        # << nouvelle ligne
	var uv_center : Vector2 = screen_pos / Vector2(get_viewport().size)
	shader.set_shader_parameter("hole_center_uv", uv_center)

	# 2. rayon / strength -------------------------------------------------
	var radius_uv : float = _radius_px / float(get_viewport().size.x)
	shader.set_shader_parameter("radius_uv", radius_uv)
	shader.set_shader_parameter("strength", _strength)
