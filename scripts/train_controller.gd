extends Node

signal update_train_direction(dir: int)
signal update_train_moving(dir: int)

var train: AnimatableBody3D
var animation_player: AnimationPlayer
var direction := -1
var moving := 0
#var max_speed = 0 # Will eventually move all these parameters from level to here

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_train_direction.connect(_on_update_train_direction)
	update_train_moving.connect(_on_update_train_moving)


func _on_update_train_direction():
	direction *= -1
	if direction == 1:
		animation_player.play("toggle_direction_lever")
	elif direction == -1:
		animation_player.play_backwards("toggle_direction_lever")
	else:
		print("invalid direction")


func _on_update_train_moving():
	moving = 1 - moving
	if moving == 1:
		animation_player.play("toggle_engine_lever")
	elif moving == 0:
		animation_player.play_backwards("toggle_engine_lever")
	else:
		print("invalid direction")
