extends Node

# Settings
var reset_velocity_on_shot: bool = false
var can_shoot_while_moving: bool = true
var hovering_shot_info: bool = false
var reverse_mouse_draw: bool = true
var funny_number: float = 420.
var multi_ball_mode: bool = false
var is_fullscreen:bool = false
var sfx_volume: float = 1. #TODO: control Sfx audio bus volume with this
var music_volume: float = 1. #TODO: control Music audio bus volume with this

var ui_alpha: float = .8

# Game
var shot_power: float = 1998. - 420.

var max_mouse_line_length: float = 450.
var min_shooting_velocity: float = 50.
var start_offset_range: float = 15.

var time_needed_to_score: float = .6
var max_distance_to_score: float = 6.
var max_velocity_to_score: float = 10.

var mouse_pos_at_click: Vector2

var shot_count: int = 0
var current_par: int = 0

func _ready() -> void:
	randomize()
	shot_count = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	if event.is_action_pressed("toggle_fullscreen"): toggle_fullscreen(!is_fullscreen)
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
		_ready()

func toggle_fullscreen(setting: bool):
	is_fullscreen = setting
	if is_fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
