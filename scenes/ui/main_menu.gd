extends CanvasLayer

@onready var button_join: Button = %ButtonJoin
@onready var button_quit: Button = %ButtonQuit

const WORLD_FOREST = preload("uid://tb21kw5g8pwt")
const PLAYER = preload("res://scenes/player/player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_join.pressed.connect(on_join)
	button_quit.pressed.connect(func(): get_tree().quit())
	
	if OS.has_feature("server"):
		Network.start_server()
		add_world()
		hide()

func on_join():
	Network.join_server()
	add_world()
	hide()


func add_world():
	var new_world = WORLD_FOREST.instantiate()
	get_tree().current_scene.add_child.call_deferred(new_world)
