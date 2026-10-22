extends PlayerState


func _on_moving_state_physics_processing(_delta: float) -> void:
	if player_controller._input_dir.length() == 0 and player_controller.velocity.length() < 0.5:
		player_controller.state_chart.send_event("onIdle")
