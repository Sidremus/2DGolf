extends Node

# Settings
var reset_velocity_on_shot: bool = false
var can_shoot_while_moving: bool = true
var reverse_mouse_draw: bool = true
var joke_number: float = 420.
var multi_ball_mode: bool = false

var sfx_volume: float = 1. #TODO: control Sfx audio bus volume with this
var music_volume: float = 1. #TODO: control Music audio bus volume with this

var ui_alpha: float = .8

# Game
var shot_power: float = 1000.

var max_mouse_line_length: float = 250.
var min_shooting_velocity: float = 50.

var time_needed_to_score: float = .6
var max_distance_to_score: float = 6.
var max_velocity_to_score: float = 10.

var mouse_pos_at_click: Vector2

var shot_count: int = 0
var level_select_scene = preload("res://scenes/level_selection.tscn")

func _ready() -> void:
	randomize()
	shot_count = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
		_ready()

func go_to_level_select():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(level_select_scene)
