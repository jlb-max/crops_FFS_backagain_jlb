# TilledSoil.gd (Version finale corrigée)
extends TileMapLayer

func _ready() -> void:
	WeatherManager.weather_changed.connect(on_weather_changed)
	SoilManager.register_tilled_soil_layer(self)

func on_weather_changed(new_weather: int) -> void:
	if new_weather == WeatherManager.Weather.RAINING:
		water_all_tiles()
		print("Il pleut ! Les terres labourées sont arrosées (sauf celles protégées).")

func water_all_tiles() -> void:
	var heat_emitters = get_tree().get_nodes_in_group("heat_emitters")
	var tilled_tiles = get_used_cells()
	
	for tile_coord in tilled_tiles:
		var is_protected = false
		
		# --- CORRECTION ---
		# On convertit les coordonnées de la tuile en position GLOBALE.
		var tile_global_pos = to_global(map_to_local(tile_coord))
		
		for emitter in heat_emitters:
			var heat_component = emitter.get_node_or_null("HeatComponent")
			if heat_component:
				# On compare maintenant deux positions globales, le calcul est juste.
				var distance = tile_global_pos.distance_to(emitter.global_position)
				
				if distance < heat_component.heat_data.heat_radius:
					is_protected = true
					break
		
		if not is_protected:
			SoilManager.add_wet_tile(tile_coord)
