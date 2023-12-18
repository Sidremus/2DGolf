extends Area2D

func _physics_process(delta: float) -> void:
	if has_overlapping_bodies():
		var overlapping_bodies:= get_overlapping_bodies()
		for body in overlapping_bodies:
			if body is Ball:
				body.time_in_goal += delta
				var score_cond: bool = !body.freeze # not frozen
				score_cond = score_cond && body.time_in_goal >= Game.time_needed_to_score # enough time in goal
				score_cond = score_cond && global_position.distance_to(body.global_position) <= Game.max_distance_to_score # close enough to center
				score_cond = score_cond && body.linear_velocity.length() <= Game.max_velocity_to_score # slow enough
				if score_cond: body.score(global_position)

func _on_body_exited(body: Node2D) -> void:
	if body is Ball: body.time_in_goal = 0.
