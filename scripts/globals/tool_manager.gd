# tool_manager.gd (Version corrigée et complète)
extends Node

# --- LIGNE MANQUANTE AJOUTÉE ---
# Ce signal préviendra l'interface quand l'outil change
signal tool_selected(item_data: ItemData)

var selected_item_data: ItemData = null

func select_item(item: ItemData) -> void:
	selected_item_data = item
	# On émet le signal avec l'item (ou null si on désélectionne)
	tool_selected.emit(selected_item_data) 
	print("Item sélectionné : ", item.item_name if item else "Aucun")

func get_selected_item() -> ItemData:
	return selected_item_data

func get_selected_action() -> ItemData.ActionType:
	if selected_item_data:
		return selected_item_data.action_type
	return ItemData.ActionType.NONE
