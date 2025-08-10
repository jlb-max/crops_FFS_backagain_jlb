@tool
extends VBoxContainer

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel

# La fonction est plus simple, elle ne prend plus de nom
func set_data(item_icon: Texture2D, possessed: int, required: int) -> void:
	await ready
	
	icon.texture = item_icon
	quantity_label.text = "%d/%d" % [possessed, required]
	
	# La logique de couleur reste la même
	if possessed < required:
		quantity_label.add_theme_color_override("font_color", Color.RED)
	else:
		quantity_label.add_theme_color_override("font_color", Color.GREEN)
