extends Area2D

func _physics_process(delta: float) -> void:
	if has_overlapping_bodies():
		var overlapping_bodies:= get_overlapping_bodies()
		for body in overlapping_bodies:
			if body is Ball:
				body.apply_central_force((global_position - body.global_position).normalized() * Game.goal_gravity)
				body.time_in_goal += delta
				if body.time_in_goal >= Game.time_needed_to_score && !body.freeze: body.score(global_position)

func _on_body_exited(body: Node2D) -> void:
	if body is Ball: body.time_in_goal = 0.
