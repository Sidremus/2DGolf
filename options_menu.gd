extends Control

@onready var checkbox_toggle_fullscreen: CheckBox = $CheckboxToggleFullscreen
@onready var checkbox_can_shoot_while_moving: CheckBox = $CheckboxCanShootWhileMoving
@onready var checkbox_reset_velocity_on_shot: CheckBox = $CheckboxResetVelocityOnShot
@onready var checkbox_reverse_mouse_draw: CheckBox = $CheckboxReverseMouseDraw

func _on_checkbox_toggle_fullscreen_toggled(toggled_on: bool) -> void:
	Game.toggle_fullscreen(toggled_on)

func _on_checkbox_can_shoot_while_moving_toggled(toggled_on: bool) -> void:
	Game.can_shoot_while_moving = toggled_on

func _on_checkbox_reset_velocity_on_shot_toggled(toggled_on: bool) -> void:
	Game.reset_velocity_on_shot = toggled_on

func _on_checkbox_reverse_mouse_draw_toggled(toggled_on: bool) -> void:
	Game.reverse_mouse_draw = !toggled_on

func _process(_delta: float) -> void:
	checkbox_toggle_fullscreen.button_pressed = Game.is_fullscreen
	checkbox_can_shoot_while_moving.button_pressed = Game.can_shoot_while_moving
	checkbox_reset_velocity_on_shot.button_pressed = Game.reset_velocity_on_shot
	checkbox_reverse_mouse_draw.button_pressed = !Game.reverse_mouse_draw

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
