extends Node3D

@export var weapon_node: Node3D
@export var shoot_timer : Timer

var target : Node3D
signal shoot_weapon_main

func _ready():
	target = get_tree().get_first_node_in_group("Train")

func _process(delta):
	if target == null:
		return
	look_at(target.global_position)

func recalc_targets():
	var player_list: Array = get_tree().get_nodes_in_group("Players")
	print("Player " + str(multiplayer.get_unique_id()) + "has list " + str(player_list))
	var closest_target_dist: float = 9000
	for i in player_list:
		var player_distance = global_position.distance_to(i.global_position)
		if player_distance < closest_target_dist:
			target = i
			closest_target_dist = player_distance
	print("the peer id of " + str(multiplayer.get_unique_id()) + " targeted the player " + str(target))

func on_triggered(body):
	target = body

func check_distance():
	var distance_to_target = global_position.distance_squared_to(target.global_position)
	return distance_to_target

func shoot_gun():# use this function to make enemies shoot gun. Likely pass the target rotation to the weapon, down to weapon, back up to this script to pass through to projectile handler
	shoot_weapon_main.emit(target)
	shoot_timer.start()

func _on_shoot_timer_timeout():
	shoot_gun()

func _on_weapon_projectile_info(projectile_position,projectile_rotation,projectile_speed): #From weapon child node, this is sent to the projectilehandler singleton
	ProjectileHandler.shoot_ball.rpc_id(multiplayer.get_unique_id(), projectile_position,projectile_rotation, projectile_speed)


func _on_detectionarea_body_entered(body):
	if body.is_in_group("Train"):
		on_triggered(body)
