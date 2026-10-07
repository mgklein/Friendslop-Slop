extends CanvasLayer

@onready var button_join: Button = %ButtonJoin
@onready var button_quit: Button = %ButtonQuit

const WORLD_FOREST = preload("uid://tb21kw5g8pwt")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_join.pressed.connect(on_join)
	button_quit.pressed.connect(func(): get_tree().quit())

func on_join():
	var new_world = WORLD_FOREST.instantiate()
	get_tree().current_scene.add_child(new_world)
	hide()
