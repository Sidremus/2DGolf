extends Node2D

@export var par_value: int = 2

func _ready() -> void:
	Game.shot_count = 0
	Game.current_par = par_value
