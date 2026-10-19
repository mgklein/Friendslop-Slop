extends Node


var pause_menu: String = "uid://bs6ixfot8ct67"


func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu") and Global.game_controller.player_controller:
		if not Global.game_controller.current_menu.visible:
			Global.game_controller.change_menu_scene(pause_menu)
			Global.game_controller.current_menu.show()
			#Global.game_controller.current_hud.hide()
		else:
			Global.game_controller.current_menu.hide()
			#Global.game_controller.current_hud.show()
