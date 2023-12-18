extends RigidBody2D
class_name Ball

@onready var mouse_line: Line2D = $MouseLine
@onready var aim_line: Line2D = $AimLine
@onready var power_line: Line2D = $PowerLine

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var is_shooting: bool = false
var can_shoot: bool = true
var is_selected: bool = false
var time_in_goal: float = 0.
var score_tween: Tween

func _input(event: InputEvent) -> void:
	if freeze: return
	if !is_selected && Game.multi_ball_mode: return
	if event.is_action_pressed("shoot") && can_shoot && !is_shooting: begin_shot()
	if event.is_action_released("shoot") && is_shooting: finish_shot()
	if event.is_action_pressed("cancel_shot") && is_shooting: is_shooting = false

func _on_mouse_entered() -> void: is_selected = true

func _on_mouse_exited() -> void: is_selected = is_shooting

func _process(delta: float) -> void:
	mouse_line.visible = is_shooting
	aim_line.visible = is_shooting
	power_line.self_modulate.a = Game.ui_alpha if is_shooting else 0.
	
	if is_shooting && (is_selected || !Game.multi_ball_mode):
		mouse_line.global_position = Game.mouse_pos_at_click
		mouse_line.points[1] = mouse_line.to_local(get_global_mouse_position()).limit_length(Game.max_mouse_line_length)
		aim_line.points[1] = aim_line.points[1].move_toward(-mouse_line.to_local(get_global_mouse_position()).normalized() * Game.max_mouse_line_length * .2, 500.*delta)
		power_line.points[1].y = -(mouse_line.points[1].length() / Game.max_mouse_line_length) * (Game.max_mouse_line_length / 2.)
		
		var color_lerp:float = (mouse_line.points[1].length() / Game.max_mouse_line_length)
		var col = Color.PALE_TURQUOISE.lerp(Color.PALE_GOLDENROD.lerp(Color.PALE_VIOLET_RED, color_lerp), color_lerp)
		power_line.default_color = Color(col, mouse_line.default_color.a *.5)

func begin_shot():
	Game.mouse_pos_at_click = get_global_mouse_position()
	is_shooting = true

func finish_shot():
	is_shooting = false
	is_selected = is_shooting || !Game.multi_ball_mode
	if Game.reset_velocity_on_shot:
		linear_velocity = -mouse_line.points[1].normalized() * Game.shot_power * (mouse_line.points[1].length() / Game.max_mouse_line_length)
	else:
		apply_central_impulse(-mouse_line.points[1].normalized() * Game.shot_power * (mouse_line.points[1].length() / Game.max_mouse_line_length))
	Game.shot_count += 1
	print_debug(Game.shot_count)

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if freeze: return
	var slowing_fac: float = clampf((1. - (linear_velocity.length() / Game.shot_power)) * (1. / (Engine.physics_ticks_per_second as float)), 0., 1.)
	if !sleeping: linear_velocity = linear_velocity.move_toward(Vector2.ZERO, slowing_fac)
	
	can_shoot = Game.can_shoot_while_moving || linear_velocity.length() <= Game.min_shooting_velocity
	if can_shoot: collision_shape_2d.debug_color = Color(Color.WHITE, .5)
	else: collision_shape_2d.debug_color = Color(Color.GRAY, .2)

func _ready() -> void:
	mouse_line.self_modulate.a = Game.ui_alpha
	mouse_line.top_level = true
	
	aim_line.self_modulate.a = Game.ui_alpha
	mouse_line.self_modulate.a = Game.ui_alpha
	
	power_line.visible = true
	power_line.top_level = true
	power_line.global_position = Vector2(75., Game.max_mouse_line_length + 75.)
	power_line.modulate.a = Game.ui_alpha

func score(target_pos: Vector2):
	freeze = true
	is_shooting = false
	score_tween = get_tree().create_tween()
	score_tween.set_parallel(true)
	score_tween.set_ease(Tween.EASE_OUT)
	score_tween.set_trans(Tween.TRANS_ELASTIC)
	score_tween.tween_property(self, "global_position", target_pos, .8)
	score_tween.set_ease(Tween.EASE_OUT_IN)
	score_tween.set_trans(Tween.TRANS_BOUNCE)
	score_tween.tween_property(self, "scale", scale * 0., .8)
	score_tween.set_parallel(false)
	score_tween.tween_callback(Game.go_to_level_select).set_delay(2.)
