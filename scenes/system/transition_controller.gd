class_name SceneTransitionController extends Control

@onready var background: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func transition(animation: String, seconds: float) -> void:
	animation_player.play(animation, -1.0, 1 / seconds)
