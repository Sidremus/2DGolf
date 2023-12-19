extends RigidBody2D
class_name Ball

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var mouse_line: Line2D = $MouseLine
@onready var aim_line: Line2D = $AimLine
@onready var power_line: Line2D = $PowerLine
@onready var crosshair: Sprite2D = $Crosshair
@onready var last_shot_info_label: Label = $LastShotInfo
@onready var current_shot_info_label: Label = $CurrentShotInfo
@onready var end_screen_label: Label = $"../EndScreen/EndScreenLabel"

var is_shooting: bool = false
var can_shoot: bool = true
var is_selected: bool = false
var time_in_goal: float = 0.
var last_shot_power: float = 0.
var last_shot_angle: float = 0.
var score_tween: Tween

# Sound
@onready var ball_in_hole_AS: AudioStreamPlayer2D = $BallInHoleAS
@onready var ball_hit_01_AS: AudioStreamPlayer2D = $BallHit01AS
@onready var ball_hit_02_AS: AudioStreamPlayer2D = $BallHit02AS
@onready var hole_in_one_AS: AudioStreamPlayer2D = $HoleInOneAS
@onready var ball_impact_AS: AudioStreamPlayer2D = $BallImpactAS
@onready var ball_impact_volume_ref: float = 1.

func _input(event: InputEvent) -> void:
	if freeze: return
	if !is_selected && Game.multi_ball_mode: return
	if event.is_action_pressed("shoot") && can_shoot && !is_shooting: begin_shot()
	if event.is_action_released("shoot") && is_shooting: finish_shot()
	if event.is_action_pressed("cancel_shot") && is_shooting: is_shooting = false

func _on_mouse_entered() -> void: is_selected = true

func _on_mouse_exited() -> void: is_selected = is_shooting

func _process(delta: float) -> void:
	crosshair.global_position = get_global_mouse_position()
	mouse_line.visible = is_shooting
	aim_line.visible = is_shooting
	power_line.self_modulate.a = Game.ui_alpha if is_shooting else 0.
	
	if is_shooting && (is_selected || !Game.multi_ball_mode):
		mouse_line.global_position = Game.mouse_pos_at_click
		mouse_line.points[1] = mouse_line.to_local(get_global_mouse_position()).limit_length(Game.max_mouse_line_length)
		var directional_fac: float = -1. if !Game.reverse_mouse_draw else 1.
		var aim_line_vec: Vector2 = (directional_fac * mouse_line.to_local(get_global_mouse_position())).limit_length(Game.max_mouse_line_length * .75)
		aim_line.points[1] = aim_line_vec 
		aim_line.position = aim_line_vec.normalized() * Game.max_mouse_line_length * .1
		power_line.points[1].y = -(mouse_line.points[1].length() / Game.max_mouse_line_length) * (Game.max_mouse_line_length / 2.)
		
		var color_lerp:float = (mouse_line.points[1].length() / Game.max_mouse_line_length)
		var col = Color.PALE_TURQUOISE.lerp(Color.PALE_GOLDENROD.lerp(Color.PALE_VIOLET_RED, color_lerp), color_lerp)
		power_line.default_color = Color(col, mouse_line.default_color.a *.5)
	update_UI(delta)

func update_UI(delta: float):
	var t: String = "Shots: " + str(Game.shot_count)
	if Game.shot_count > 0:
		t = t + "\n\nLast: " 
		t = t + "\n  Power: " + str(last_shot_power).pad_decimals(1) + "%"
		t = t + "\n  Angle: " + str(snappedf(rad_to_deg(last_shot_angle + PI), .1)).pad_decimals(1) + "°"
	last_shot_info_label.text = t
	if is_shooting && (is_selected || !Game.multi_ball_mode):
		var power_lerp: float = (mouse_line.points[1].length() / Game.max_mouse_line_length)
		var shot_vec: Vector2 = -mouse_line.points[1].normalized() * Game.shot_power * power_lerp
		if !Game.reverse_mouse_draw: shot_vec *= -1.
		
		var angle: float = Vector2.UP.angle_to(shot_vec)
		var new_pos: Vector2 = mouse_line.to_global(mouse_line.points[1]) - current_shot_info_label.size / 2. + mouse_line.points[1].normalized() * Game.max_mouse_line_length * .3
		current_shot_info_label.position = current_shot_info_label.position.move_toward(new_pos, delta * maxf(Game.funny_number, current_shot_info_label.position.distance_to(new_pos)) * 2.)
		
		t = "Power: " + str(snappedf(power_lerp * 100., 1.)).pad_decimals(1) + "%"
		t = t + "\nAngle: " + str(snappedf(rad_to_deg(angle + PI), .1)).pad_decimals(1) + "°"
		current_shot_info_label.text = t
		last_shot_info_label.text = last_shot_info_label.text + "\n\nCurrent Shot:" + t
	current_shot_info_label.visible = is_shooting && (is_selected || !Game.multi_ball_mode)

func begin_shot():
	Game.mouse_pos_at_click = get_global_mouse_position()
	current_shot_info_label.position = get_global_mouse_position() - current_shot_info_label.size /2. - (Game.mouse_pos_at_click - get_global_mouse_position()).normalized() * Game.max_mouse_line_length * .3
	is_shooting = true

func finish_shot():
	is_shooting = false
	if get_global_mouse_position() == Game.mouse_pos_at_click: return
	
	var power_lerp: float = (mouse_line.points[1].length() / Game.max_mouse_line_length)
	
	if randf() > .66:
		ball_hit_01_AS.pitch_scale = lerpf(.5, 1.5, power_lerp) + randf_range(-.1, .1)
		ball_hit_01_AS.play()
	else:
		ball_hit_01_AS.pitch_scale = lerpf(.5, 1.5, power_lerp) + randf_range(-.1, .1)
		ball_hit_01_AS.play()
	is_selected = is_shooting || !Game.multi_ball_mode
	var shot_vec:Vector2 = -mouse_line.points[1].normalized() * Game.shot_power * power_lerp
	if Game.reset_velocity_on_shot:
		linear_velocity = shot_vec if !Game.reverse_mouse_draw else -shot_vec
	else:
		apply_central_impulse(shot_vec if !Game.reverse_mouse_draw else -shot_vec)
	
	Game.shot_count += 1
	
	last_shot_power = snappedf(power_lerp * 100., 1.)
	last_shot_angle = Vector2.UP.angle_to(shot_vec)

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if freeze: return
	var slowing_fac: float = clampf((1. - (linear_velocity.length() / Game.shot_power)) * (1. / (Engine.physics_ticks_per_second as float)), 0., 1.)
	if !sleeping: linear_velocity = linear_velocity.move_toward(Vector2.ZERO, slowing_fac)
	
	can_shoot = Game.can_shoot_while_moving || linear_velocity.length() <= Game.min_shooting_velocity
	if can_shoot: collision_shape_2d.debug_color = Color(Color.WHITE, .5)
	else: collision_shape_2d.debug_color = Color(Color.GRAY, .2)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	mouse_line.self_modulate.a = Game.ui_alpha
	mouse_line.top_level = true
	mouse_line.self_modulate.a = Game.ui_alpha
	
	aim_line.self_modulate.a = Game.ui_alpha
	
	power_line.visible = true
	power_line.top_level = true
	power_line.global_position = Vector2(50., Game.max_mouse_line_length + 50.)
	power_line.modulate.a = Game.ui_alpha
	
	crosshair.top_level = true
	
	last_shot_info_label.top_level = true
	last_shot_info_label.global_position = Vector2(60., 50.)
	current_shot_info_label.top_level = true
	
	ball_impact_volume_ref = ball_impact_AS.volume_db
	var offset_vec: Vector2 = Vector2(randf_range(-Game.start_offset_range, Game.start_offset_range),randf_range(-Game.start_offset_range, Game.start_offset_range)).limit_length(Game.start_offset_range)
	global_position += offset_vec.rotated(randf_range(-TAU, TAU))

func score(target_pos: Vector2):
	freeze = true
	is_shooting = false
	crosshair.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Game.shot_count == 1: hole_in_one_AS.play()
	
	ball_in_hole_AS.pitch_scale = randf_range(.75, 1.25)
	ball_in_hole_AS.play()
	score_tween = get_tree().create_tween()
	score_tween.set_parallel(true)
	score_tween.set_ease(Tween.EASE_OUT)
	score_tween.set_trans(Tween.TRANS_ELASTIC)
	score_tween.tween_property(self, "global_position", target_pos, .8)
	score_tween.tween_property(self, "scale", scale * 0., .8)
	score_tween.set_parallel(false)
	var end_screen: Control = get_tree().get_first_node_in_group("Endscreen")
	score_tween.tween_callback(end_screen.show).set_delay(2.)
	end_screen_label.text = "FINISH!\n\nShots: " + str(Game.shot_count) + "\n  Par: " + str(Game.current_par)

func _on_body_entered(_body: Node) -> void:
	ball_impact_AS.pitch_scale = lerpf(1.2, .8, linear_velocity.length() / Game.shot_power) + randf_range(-.025, .025)
	ball_impact_AS.volume_db = lerpf(ball_impact_volume_ref - 5., ball_impact_volume_ref + 5, linear_velocity.length() / Game.shot_power)
	ball_impact_AS.play()
