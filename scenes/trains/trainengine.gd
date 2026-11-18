class_name Train
extends AnimatableBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TrainController.train = self
	TrainController.animation_player = animation_player
