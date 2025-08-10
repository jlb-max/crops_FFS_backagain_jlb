# HeaterFuelMenu.gd
extends PanelContainer

# On gardera une référence à la machine pour lui parler
var heater_machine_ref: Node
@export var biofuel_item_resource: Resource # Glisse ton BiofuelItem.tres ici



@onready var count_label: Label = $VBoxContainer/HBoxContainer/CountLabel
@onready var feed_button: Button = $VBoxContainer/HBoxContainer/FeedButton
@onready var cancel_button: Button = $VBoxContainer/HBoxContainer/CancelButton


func _ready():
	# 1. On s'enregistre auprès du GameManager
	GameManager.register_heater_fuel_menu(self)
	
	# 2. On connecte les boutons
	feed_button.pressed.connect(_on_feed_button_pressed)
	cancel_button.pressed.connect(close_menu)
	
	# 3. On s'assure d'être caché au démarrage
	hide()

# Fonction appelée par le GameManager
func open_menu(machine_node: Node):
	heater_machine_ref = machine_node
	
	# On met à jour le label avec la quantité que le joueur possède
	var player_biofuel_count = InventoryManager.get_item_count(biofuel_item_resource)
	count_label.text = "Vous avez : %d" % player_biofuel_count
	
	# On désactive le bouton si le joueur n'a pas de biofuel
	feed_button.disabled = player_biofuel_count == 0

	show()

func _on_feed_button_pressed():
	if heater_machine_ref:
		heater_machine_ref.start_burning_fuel()
	close_menu()

func close_menu():
	hide()
