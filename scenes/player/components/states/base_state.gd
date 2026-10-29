class_name PlayerState
extends Node


@export var debug: bool = false

var player_controller: PlayerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if %StateMachine and %StateMachine is PlayerStateMachine:
		player_controller = %StateMachine.player_controller
