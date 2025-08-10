# res://crafting/ingredient.gd
@tool
class_name Ingredient
extends Resource

# On remplace "Resource" par "CollectibleData" pour plus de sécurité
@export var item: CollectibleData 
@export_range(1, 999) var quantity: int = 1
