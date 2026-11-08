extends Node

#This will handle all projectiles in the scene.

@onready var root_node = get_tree()

var game_controller: GameController
var level: Node3D
var spawn_container: Node3D

const BALL = preload("uid://dlsk78b4aki17") #Eventually, make a dictionary pointing to specific projectiles with specific IDs. Currently there is only one projectile.


@rpc("any_peer", "call_local")
func shoot_ball(pos, dir, force):
	var new_ball: RigidBody3D = BALL.instantiate() #Eventually, this will create a projectile from the dictionary of projectiles
	new_ball.source = multiplayer.get_remote_sender_id()
	new_ball.position = pos
	spawn_container.add_child(new_ball, true)
	new_ball.apply_central_impulse(dir * force)
