# Weather_Manager.gd
extends Node



# On définit les types de météo possibles
enum Weather { SUNNY, RAINING }

# Signal émis quand la météo change
signal weather_changed(new_weather: Weather)

# Météo actuelle
var current_weather: Weather = Weather.SUNNY

# Probabilité de pluie (ici, 25%)
@export var rain_chance: float = 0.25




func _ready() -> void:
	# Le WeatherManager écoute le passage des jours
	DayAndNightCycleManager.time_tick_day.connect(on_day_passed)
	# On choisit une météo de départ
	randomize_weather()

# Chaque nouveau jour, on décide de la météo
func on_day_passed(day: int) -> void:
	randomize_weather()

func randomize_weather() -> void:
	var old_weather = current_weather
	
	if randf() < rain_chance:
		current_weather = Weather.RAINING
	else:
		current_weather = Weather.SUNNY
	
	# Si la météo a effectivement changé, on prévient tout le monde
	if current_weather != old_weather:
		weather_changed.emit(current_weather)
		print("La météo a changé : ", Weather.keys()[current_weather])

func get_current_weather() -> Weather:
	return current_weather
