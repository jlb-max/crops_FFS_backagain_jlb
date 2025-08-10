## game_config.gd
extends Node
## Quand false : la jauge HP descend, mais le joueur ne s’évanouit jamais.
## Quand true  : faint activé (comportement “normal”).

@export var ENABLE_FAINTING : bool = true
