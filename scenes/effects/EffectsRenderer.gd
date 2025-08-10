# res://scenes/effects/EffectsRenderer.gd (Approche Finale et Robuste)
extends ColorRect

func _ready() -> void:
	print("--- EffectsRenderer: Trying to connect to manager... ---")
	
	# On accède au singleton DIRECTEMENT via l'arbre de scène. C'est la méthode la plus fiable.
	# On utilise get_node_or_null pour éviter un crash si le chemin est incorrect.
	var manager = get_node_or_null("/root/VisualEffectsManager")
	
	if manager:
		print("    SUCCESS: Found VisualEffectsManager node in the scene tree.")
		
		# On vérifie que la fonction existe avant de l'appeler pour éviter toute erreur.
		if manager.has_method("set_active_material"):
			manager.set_active_material(self.material)
			print("    --> Connection successful. Material has been set.")
		else:
			print("    !!! FAILURE: Manager node found, but the 'set_active_material' function is missing from its script!")
	else:
		print("    !!! FAILURE: Could not find node at path '/root/VisualEffectsManager'.")
		print("    Please double-check the 'Node Name' in your Autoload settings.")
