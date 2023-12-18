extends Node

# Settings
var reset_velocity_on_shot: bool = false
var can_shoot_while_moving: bool = true
var ui_alpha: float = .8
var multi_ball_mode: bool = false

# Game
var shot_power: float = 1000.
var goal_gravity: float = 100.
var max_mouse_line_length: float = 250.
var min_shooting_velocity: float = 50.
var time_needed_to_score: float = 2.
var mouse_pos_at_click: Vector2

var shot_count: int = 0

func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	randomize()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): get_tree().quit()

