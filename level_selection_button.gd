extends Button
@export var level_path: String

func _on_button_up() -> void:
	get_tree().change_scene_to_file(level_path)

func _ready() -> void:
	button_up.connect(_on_button_up)
