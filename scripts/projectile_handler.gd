extends Node

#This will handle all projectiles in the scene.

@onready var root_node = get_tree()

var game_controller: GameController
var level: Node3D
var spawn_container: Node3D
var proj_speed: float = 40.0

const BALL = preload("uid://dlsk78b4aki17") #Eventually, make a dictionary pointing to specific projectiles with specific IDs. Currently there is only one projectile.

var bullet = preload("uid://ciwb2wf4qn2yy")

func _process(delta):
	if spawn_container == null:
		return
	if spawn_container.get_child_count() == 0:
		return
	else:
		move_projectiles(delta)

@rpc("authority", "call_local") # This should likely only be called by the server. The clients should be able to tell the server they want to shoot and then the server shoots.
func shoot_ball(pos, dir, force):
	if !is_multiplayer_authority():
		pass
	#var new_ball: RigidBody3D = BALL.instantiate() #Eventually, this will create a projectile from the dictionary of projectiles
	#new_ball.source = multiplayer.get_remote_sender_id()
	#new_ball.position = pos
	#spawn_container.add_child(new_ball, true)
	#new_ball.apply_central_impulse(dir * force) # Once new projectile handling is added, this will be obsolete
	var new_bullet = bullet.instantiate()
	#new_bullet.source = multiplayer.get_remote_sender_id()
	spawn_container.add_child(new_bullet, true)
	new_bullet.global_position = pos
	new_bullet.global_rotation = dir
	new_bullet.get_child(3).body_entered.connect(on_projectile_collide)


func move_projectiles(delta):
	for i in spawn_container.get_children():
		i.position += i.global_rotation * proj_speed * delta

	# This will be used to move all projectiles in the scene. They likely will not be physics objects anymore. I don't think there's any need. This will replace the functions in shoot ball function
	# This function will also be called in a for loop under the process function

@rpc("authority","call_local")
func on_projectile_collide(body): # Handles projectile collisions with bodies
	if body == null:
		return
	elif body.is_in_group("Enemies") and is_multiplayer_authority():
		body.take_damage.rpc(1,multiplayer.get_unique_id()) # Sends take damage call to all peers to sync
		print(body)
