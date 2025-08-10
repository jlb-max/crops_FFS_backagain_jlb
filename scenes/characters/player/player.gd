#player.gd
class_name Player
extends CharacterBody2D

# Variables pour l'effet de balancement
@export var swing_speed: float = 3.0
@export var swing_angle: float = 15.0 # Angle maximum en degrés
@export var pulse_speed: float = 5.0
@export var pulse_amount: float = 0.08

@onready var held_item_sprite: Sprite2D = $HeldItemSprite
@onready var hit_component: HitComponent = $HitComponent

@export var game_tilemap: TileMapLayer
@onready var curseur_visee: Node2D = $CurseurDeVisee
@onready var state_machine = $StateMachine
@onready var curseur_color: ColorRect = $CurseurDeVisee/ColorPreview
@onready var curseur_preview: Sprite2D = $CurseurDeVisee/ItemPreview
@export var couleur_possible: Color = Color(0.2, 1, 0.2, 0.5) # Vert semi-transparent
@export var couleur_impossible: Color = Color(1, 0.2, 0.2, 0.5) # Rouge semi-transparent

var current_item: ItemData = null

var player_direction: Vector2


func _ready() -> void:
	ToolManager.tool_selected.connect(on_item_selected)
	SoilManager.register_wetness_overlay(%WetnessOverlay)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"): # "action" est votre bouton d'action principal
		
		# On récupère l'action de l'item actuellement en main
		var current_action = ToolManager.get_selected_action()
		
		# On utilise un "match" pour dire à la machine d'état où aller
		match current_action:
			ItemData.ActionType.CHOP:
				state_machine.transition_to("Chopping") # Le nom de votre état pour couper du bois
			ItemData.ActionType.TILL:
				state_machine.transition_to("Tilling") # Le nom de votre état pour labourer
			ItemData.ActionType.WATER:
				state_machine.transition_to("Watering") # ...etc.
			# Le PLANT se fait via le CropsCursorComponent, donc pas besoin ici.

func _process(delta: float) -> void:
	# On vérifie que la TileMap est bien connectée pour éviter une erreur
	if not game_tilemap:
		return

	# 1. Obtenir la position GLOBALE de la souris
	var mouse_position = get_global_mouse_position()

	# 2. Convertir cette position en coordonnées de la grille de la TileMap
	var map_coordinates = game_tilemap.local_to_map(mouse_position)

	# 3. Placer le curseur sur le coin de la tuile correspondante
	curseur_visee.global_position = game_tilemap.map_to_local(map_coordinates)

	# --- NOUVELLE LOGIQUE POUR LA DISTANCE ET LA COULEUR ---

	# A. Obtenir la tuile sur laquelle se trouve le joueur
	var player_tile_coords = game_tilemap.local_to_map(self.global_position)

	# B. Calculer la distance (en nombre de tuiles) entre le joueur et le curseur
	var distance = (player_tile_coords - map_coordinates).abs()

	# C. Vérifier si la distance est acceptable (0 ou 1 tuile dans chaque axe)
	if distance.x <= 1 and distance.y <= 1:
		# On applique la couleur au ColorRect, pas au curseur entier
		curseur_color.color = couleur_possible
	else:
		curseur_color.color = couleur_impossible
		
	if held_item_sprite.visible:
		# On calcule le nouvel angle en utilisant le sinus du temps
		var time = Time.get_ticks_msec() / 1000.0 # Temps en secondes
		var new_angle = sin(time * swing_speed) * swing_angle
		held_item_sprite.rotation_degrees = new_angle


func on_item_selected(item: ItemData) -> void:
	current_item = item
	
	# --- DÉBUT DE LA MODIFICATION ---
	# Si on a un item en main et que c'est une graine (ActionType.PLANT)
	if item and item.action_type == ItemData.ActionType.PLANT:
		# On affiche son icône sur le sprite
		held_item_sprite.texture = item.icon
		held_item_sprite.visible = true
	else:
		# Sinon, on cache le sprite
		held_item_sprite.visible = false
	# --- FIN DE LA MODIFICATION ---
	
	if item and item.action_type == ItemData.ActionType.PLACE_CRAFTABLE:
		# On cache la prévisualisation de couleur
		curseur_color.visible = false
		# On affiche la prévisualisation de l'objet
		curseur_preview.visible = true
		# On charge la texture de l'aperçu (ou de l'objet lui-même)
		curseur_preview.texture = item.icon # Ou une texture d'aperçu spécifique
	else:
		# Pour tous les autres outils, on utilise la couleur
		curseur_color.visible = true
		curseur_preview.visible = false
	
	# Le reste de votre fonction ne change pas
	if item:
		print("Le joueur a maintenant en main : ", item.item_name)
	else:
		print("Le joueur n'a plus rien en main.")
