extends PlayerState


func _on_standing_state_physics_processing(delta: float) -> void:
	player_controller.camera_controller.update_camera_height(delta, 1)
	if Input.is_action_pressed("crouch") and player_controller.is_on_floor():
		player_controller.state_chart.send_event("onCrouching")


func _on_standing_state_entered() -> void:
	player_controller.stand()
