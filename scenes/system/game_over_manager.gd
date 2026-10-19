extends Node

var player: PlayerController

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Find player
	player = get_tree().get_first_node_in_group("player")
	
	# Connect signals
	if player:
		var health_component = player.get_node_or_null("HealthComponent")
		if health_component and not health_component.died.is_connected(_on_died):
			health_component.died.connect(_on_died)
		if not player.end_game.is_connected(_on_end_game):
			player.end_game.connect(_on_end_game)


func _on_died() -> void:
	if not Global.game_controller.current_menu.visible:
		Global.game_controller.change_menu_scene("res://scenes/system/game_over_menu.tscn")
		Global.game_controller.current_menu.visible = true
		Global.game_controller.current_hud.visible = false
		get_tree().paused = true


func _on_end_game() -> void:
	if not Global.game_controller.current_menu.visible:
		Global.game_controller.change_menu_scene("res://scenes/system/end_menu.tscn")
		Global.game_controller.current_menu.visible = true
		Global.game_controller.current_hud.visible = false
		get_tree().paused = true
