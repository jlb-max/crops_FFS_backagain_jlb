# scripts/lore/LoreData.gd
@tool
class_name LoreData
extends Resource

## Le texte complet qui sera révélé à la fin.
@export_multiline var full_text: String

## Le nombre total de points de séquençage nécessaires pour compléter ce texte.
## Une plante simple pourrait en demander 100, une complexe 500.
@export var sequencing_points_required: int = 100
