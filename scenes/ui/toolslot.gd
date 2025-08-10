# ToolSlot.gd (Version finale)
extends Button

@onready var label: Label = $Label

var item_data: ItemData
var slot_index: int = -1

func update_selection_visual(selected_item: ItemData):
	# Si l'item de ce slot est celui qui est sélectionné, on lui met un style
	if item_data != null and item_data == selected_item:
		# On crée un StyleBox simple pour le focus
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color.TRANSPARENT # Fond transparent
		stylebox.border_width_bottom = 2
		stylebox.border_width_left = 2
		stylebox.border_width_right = 2
		stylebox.border_width_top = 2
		stylebox.border_color = Color.WHITE # Bordure blanche
		
		# On applique ce style au focus du bouton
		add_theme_stylebox_override("focus", stylebox)
		grab_focus() # On lui donne le focus pour afficher le style
	else:
		# Si ce n'est pas le slot sélectionné, on retire le focus
		release_focus()

func set_item(new_item: ItemData, quantity: int) -> void:
	item_data = new_item
	self.icon = item_data.icon
	label.text = str(quantity) if quantity > 1 else ""
	
	if not pressed.is_connected(ToolManager.select_item):
		pressed.connect(ToolManager.select_item.bind(item_data))

func clear_item() -> void:
	if item_data and pressed.is_connected(ToolManager.select_item):
		pressed.disconnect(ToolManager.select_item)
	item_data = null
	self.icon = null
	label.text = ""

# --- LOGIQUE DE GLISSER-DÉPOSER AJOUTÉE ---
func _get_drag_data(at_position: Vector2) -> Variant:
	if item_data:
		var preview = TextureRect.new()
		preview.texture = self.icon
		preview.size = Vector2(32, 32)
		set_drag_preview(preview)
		var data = {"item": item_data, "from_slot": slot_index, "source": "hotbar"}
		return data
	return null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	InventoryManager.merge_or_swap_slots(data.source, data.from_slot, "hotbar", self.slot_index)
