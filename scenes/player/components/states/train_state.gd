extends PlayerState


func _on_train_state_physics_processing(_delta: float) -> void:
	pass
	#if player_controller.is_on_floor() and player_controller.standing_raycast.is_colliding():
		#var collider = player_controller.standing_raycast.get_collider()
		#if not collider.name.contains("train"):
			#player_controller.reparent.bind(get_tree().current_scene).call_deferred()
			#player_controller.state_chart.send_event("onLevel")
