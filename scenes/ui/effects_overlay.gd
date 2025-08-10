#effects_overlay.gd
extends Node2D
class_name EffectsOverlay

@export var overlay_visible := false
@export var start_in_all_mode := true        # Ouvre en mode "toutes les cartes"
@export var alpha_max: float = 0.55
@export var threshold: float = 0.02
@export var z_index_overlay: int = 1000

# Fond sombre
@export var darken_background := true
@export var background_color := Color(0, 0, 0, 0.35)


enum Norm { RELATIVE, ABSOLUTE }

@export var normalize_mode: int = Norm.RELATIVE    # RELATIVE = auto par effet, ABSOLUTE = échelle fixe
@export var absolute_scale: Array[float] = [       # utilisé si ABSOLUTE
	20.0,  # OXYGEN  (ex: valeurs typiques max)
	1.0,   # LIGHT
	10.0,  # HEAT
	5.0    # GRAVITY
]


const COLORS: Array[Color] = [
	Color(0.2, 0.8, 1.0, 1.0),   # OXYGEN
	Color(1.0, 0.95, 0.2, 1.0),  # LIGHT
	Color(1.0, 0.25, 0.15, 1.0), # HEAT
	Color(0.7, 0.3, 1.0, 1.0),   # GRAVITY
]
const NAMES := ["Oxygène", "Lumière", "Chaleur", "Gravité"]

var _rects_by_effect: Array = []       # Array<Array[Rect2]>
var _colors_by_effect: Array = []      # Array<Array[Color]>
var _debug_once := false
var _show_all := true
var current_effect: int = EffectMaps.EffectType.OXYGEN

func _ready() -> void:
	add_to_group("effects_overlay")
	z_index = 10
	z_as_relative = true
	visible = overlay_visible
	EffectMaps.maps_rebuilt.connect(_on_maps_rebuilt)


func _alpha_for(et: int, v: float) -> float:
	var a: float = 0.0
	if normalize_mode == Norm.RELATIVE:
		var m: float = EffectMaps.get_max_value(et)
		if m <= 0.0001:
			return 0.0
		a = v / m
	else:
		var s: float = (absolute_scale[et] if et < absolute_scale.size() else 1.0)
		if s <= 0.0001:
			return 0.0
		a = v / s
	return clampf(a, 0.0, 1.0)

  
func is_showing_all() -> bool:
	return _show_all


func _on_maps_rebuilt(_types: Array) -> void:
	if overlay_visible:
		_rebuild_draw_cache()
		queue_redraw()




func set_overlay_visible(v: bool) -> void:
	overlay_visible = v
	visible = v
	if v:
		# Ouvre toujours en mode "toutes les couches"
		_show_all = true
		current_effect = EffectMaps.EffectType.OXYGEN
		EffectMaps.rebuild()
		_rebuild_draw_cache()
		queue_redraw()

# --- API pour la barre d’outils UI ---
func set_mode_all() -> void:
	_show_all = true
	if overlay_visible:
		_rebuild_draw_cache()
		queue_redraw()

func set_mode_single(effect: int) -> void:
	_show_all = false
	current_effect = effect
	if overlay_visible:
		_rebuild_draw_cache()
		queue_redraw()

func _cycle_effect(dir: int) -> void:
	var vals := EffectMaps.EFFECT_TYPES
	var idx := vals.find(current_effect)
	current_effect = vals[(idx + dir + vals.size()) % vals.size()]
	_rebuild_draw_cache()
	queue_redraw()

func _get_map_rect_local() -> Rect2:
	var used: Rect2i = EffectMaps.map_used_rect
	var ts: Vector2 = Vector2(EffectMaps.tile_size)
	var top_left_layer: Vector2 = EffectMaps.terrain_layer.map_to_local(used.position)
	var top_left: Vector2 = to_local(EffectMaps.terrain_layer.to_global(top_left_layer)) - ts * 0.5
	return Rect2(top_left, Vector2(used.size) * ts)

func _rebuild_draw_cache() -> void:
	_rects_by_effect.clear()
	_colors_by_effect.clear()
	if not EffectMaps.terrain_layer:
		return

	var effects := EffectMaps.EFFECT_TYPES if _show_all else [current_effect]

	for et in effects:
		var rects: Array[Rect2] = []
		var cols: Array[Color] = []
		_fill_cache_for_effect(int(et), rects, cols)
		_rects_by_effect.append(rects)
		_colors_by_effect.append(cols)

func _fill_cache_for_effect(et: int, out_rects: Array, out_cols: Array) -> void:
	var used: Rect2i = EffectMaps.map_used_rect
	var ts: Vector2 = Vector2(EffectMaps.tile_size)

	for y in range(used.position.y, used.end.y):
		for x in range(used.position.x, used.end.x):
			var cell: Vector2i = Vector2i(x, y)
			var v: float = EffectMaps.get_value(et, cell)

			var a_norm := _alpha_for(et, v)            # <-- normalisé 0..1
			if a_norm <= threshold:
				continue

			var p_layer: Vector2 = EffectMaps.terrain_layer.map_to_local(cell)
			var pos: Vector2 = to_local(EffectMaps.terrain_layer.to_global(p_layer)) - ts * 0.5
			out_rects.append(Rect2(pos, ts))

			var col: Color = COLORS[et]
			col.a = a_norm * alpha_max                # <-- plus de saturation
			out_cols.append(col)

func _draw() -> void:
	if not overlay_visible:
		return
	# 1) Fond sombre
	if darken_background:
		draw_rect(_get_map_rect_local(), background_color, true)
	# 2) Heatmaps
	for i in _rects_by_effect.size():
		var rects: Array = _rects_by_effect[i]
		var cols: Array = _colors_by_effect[i]
		for j in rects.size():
			draw_rect(rects[j], cols[j], true)
