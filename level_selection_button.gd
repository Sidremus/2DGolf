extends Button
@export var level = preload("res://scenes/level_01.tscn")

func _on_button_up() -> void:
	get_tree().change_scene_to_packed(level)
	Game.shot_count = 0
