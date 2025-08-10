# HarvestData.gd
class_name HarvestData
extends Resource

# La ressource ItemData de l'objet à récolter.
@export var harvest_item: ItemData

@export_group("Quantité Récoltée")
@export var min_yield: int = 1
@export var max_yield: int = 3
