# res://scripts/globals/EnvironmentManager.gd
extends Node

# ------------------------------------------------------------------
# Réglages généraux
# ------------------------------------------------------------------
const DEBUG_ENV : bool = true # Activer / désactiver complètement le log
const DEBUG_INTERVAL : int = 1000 # Durée entre 2 affichages de log (en ms)

# Pertes de base quand il n’y a AUCUNE source
const BASE_HEAT_LOSS : float = -2.0
const BASE_OXY_LOSS : float = -3.0
const BASE_GRAV_IMBALANCE : float = -2.0

# ------------------------------------------------------------------
# Données internes
# ------------------------------------------------------------------
var _sources : Array[EffectSource2D] = []
var _debug_accum : Array[String] = [] # Lignes en attente d’affichage
var _last_dump_ms : int = 0 # Horodatage du dernier affichage

# ------------------------------------------------------------------
# API publique : inscription / désinscription des auras
# ------------------------------------------------------------------
func register(s: EffectSource2D) -> void:
	if not _sources.has(s):
		_sources.append(s)

func unregister(s: EffectSource2D) -> void:
	_sources.erase(s)

# ------------------------------------------------------------------
# API publique : somme des effets au point donné
# ------------------------------------------------------------------
func get_local_effects(pos: Vector2) -> Dictionary:
	var heat: float = BASE_HEAT_LOSS
	var oxygen: float = BASE_OXY_LOSS
	var gravity: float = BASE_GRAV_IMBALANCE

	var dH: float = 0.0
	var dO: float = 0.0
	var dG: float = 0.0
	
	# --- NOUVEAU : On prépare des listes pour les logs ---
	var log_lines: Array[String] = []
	var warning_lines: Array[String] = []

	for s in _sources:
		if not s.is_inside_tree():
			continue

		# --- CORRECTION : On collecte les avertissements au lieu de les imprimer ---
		if s.effect_radius <= 0.0:
			warning_lines.append("AVERTISSEMENT: L'aura '%s' a un rayon invalide (<= 0)." % s.name)
			continue

		var d := pos.distance_to(s.global_position)
		if d > s.effect_radius:
			continue

		# Calculs principaux
		var f : float = 1.0 - pow(d / s.effect_radius, 2)
		var dh := s.heat_power * f
		var dox := s.oxygen_power * f
		var dg := s.gravity_power * f

		heat += dh
		oxygen += dox
		gravity += dg
		
		dH += dh
		dO += dox
		dG += dg

		# On ajoute la ligne de détail à notre liste temporaire
		if DEBUG_ENV:
			log_lines.append("%-16s  %6.1f  %4.2f  %7.2f  %7.2f  %7.2f" % [s.name, d, f, dh, dox, dg])

	# --- AFFICHAGE PÉRIODIQUE UNIQUE ---
	var now := Time.get_ticks_msec()
	if DEBUG_ENV and now - _last_dump_ms >= DEBUG_INTERVAL:
		_last_dump_ms = now # On réinitialise le timer
		
		print("\n--- RAPPORT D'ENVIRONNEMENT (toutes les %d ms) ---" % DEBUG_INTERVAL)
		
		# On affiche d'abord tous les avertissements collectés
		for warning in warning_lines:
			print(warning)
			
		# Puis on affiche le tableau des auras actives
		if not log_lines.is_empty():
			print("%-16s|%7s|%4s|%7s|%7s|%7s" % ["Source", "dist", "f", "ΔH", "ΔO₂", "ΔG"])
			print("-".repeat(54))
			for line in log_lines:
				print(line)

		# Et enfin, le résumé
		print("---")
		print("Σ ΔH=%6.2f  Σ ΔO₂=%6.2f  Σ ΔG=%6.2f   (sources actives : %d)" % [dH, dO, dG, _sources.size()])
		print("Valeurs finales à la position %s :" % str(pos.round()))
		print("  { heat:%.2f, oxygen:%.2f, gravity:%.2f }" % [heat, oxygen, gravity])
		print("----------------------------------------------------------")

	return {
		heat = heat,
		oxygen = oxygen,
		gravity = gravity
	}

func get_sources_snapshot() -> Array[EffectSource2D]:
	# filtre basique: dans l'arbre uniquement
	return _sources.filter(func(s): return s.is_inside_tree()).duplicate()
