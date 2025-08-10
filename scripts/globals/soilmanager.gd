## SoilManager.gd  (autoload)
extends Node

# ------------------------------------------------------------------
# 1.  Références aux calques (on les enregistre depuis la scène)
# ------------------------------------------------------------------
var tilled_soil_layer : TileMapLayer   = null
var wetness_overlay   : TileMapLayer   = null

func init_layers(tilled : TileMapLayer, overlay : TileMapLayer) -> void:
	tilled_soil_layer = tilled
	wetness_overlay   = overlay

# ------------------------------------------------------------------
# 2.  État interne
# ------------------------------------------------------------------
var _wet_tiles : Dictionary = {}   # { Vector2i : true }

# ------------------------------------------------------------------
# 3.  Connexions globales
# ------------------------------------------------------------------
func _ready() -> void:
	WeatherManager.weather_changed.connect(_on_weather_changed)
	DayAndNightCycleManager.time_tick_day.connect(_on_day_passed)

# ------------------------------------------------------------------
# 4.  API publique (appelée par les autres scripts)
# ------------------------------------------------------------------

const WET_TILE_SOURCE_ID  := 0
const WET_TILE_ATLAS_POS := Vector2i(0, 0)

func add_wet_tile(tile : Vector2i) -> void:
	if not tilled_soil_layer:
		push_warning("SoilManager : tilled_soil_layer NULL")
	if not wetness_overlay:
		push_warning("SoilManager : wetness_overlay NULL")
	if not tilled_soil_layer:
		push_error("SoilManager: Impossible d'arroser, la couche TilledSoil n'a pas été enregistrée !")
		return

	if tilled_soil_layer.get_cell_source_id(tile) == -1:
		return                                  # pas de TilledSoil → on ignore
	if _wet_tiles.has(tile):
		return                                  # déjà mouillé
	wetness_overlay.set_cell(tile, WET_TILE_SOURCE_ID, WET_TILE_ATLAS_POS)
	var placed_id := wetness_overlay.get_cell_source_id(tile)
	print("Overlay posé sur ", tile, "  →  source_id = ", placed_id)
	_wet_tiles[tile] = true

func add_wet_area(center : Vector2i, radius : int) -> void:
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var t := Vector2i(x, y)
			if t.distance_to(center) <= radius:
				add_wet_tile(t)                 # passe par le filtre ci‑dessus

func is_tile_wet(coords : Vector2i) -> bool:
	return _wet_tiles.has(coords)

# ------------------------------------------------------------------
# 5.  Réactions météo / nouveau jour
# ------------------------------------------------------------------
func _on_weather_changed(new_weather : int) -> void:
	if new_weather == WeatherManager.Weather.RAINING:
		_wet_all_tilled_soil()

func _wet_all_tilled_soil() -> void:
	if not tilled_soil_layer: return
	for tile in tilled_soil_layer.get_used_cells():
		add_wet_tile(tile)

func _on_day_passed(day : int) -> void:
	# S’il pleut déjà ce jour‑là, on garde l’humidité
	if WeatherManager.get_current_weather() == WeatherManager.Weather.RAINING:
		return

	# Sinon → on sèche tout
	if not wetness_overlay: return
	for tile_coord in _wet_tiles:
		wetness_overlay.erase_cell(tile_coord)
	_wet_tiles.clear()

# ------------------------------------------------------------------
# 6.  Compatibilité : mêmes fonctions qu’avant
# ------------------------------------------------------------------

## Appelée depuis player.gd
func register_wetness_overlay(overlay : TileMapLayer) -> void:
	wetness_overlay = overlay

## Appelle‑la une fois dans un script qui connaît la couche labourée
func register_tilled_soil_layer(layer : TileMapLayer) -> void:
	tilled_soil_layer = layer
