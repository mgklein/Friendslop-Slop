class_name PlayerStateMachine
extends Node


@export var debug: bool = false
@export_category("References")
@export var player_controller: PlayerController


func _process(_delta: float) -> void:
	if player_controller:
		var collision = player_controller.get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			player_controller.state_chart.set_expression_property("Standing on", collider.name)
