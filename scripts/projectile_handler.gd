extends Node

#This will handle all projectiles in the scene.

@onready var root_node = get_tree()

var game_controller: GameController
var level: Node3D
var spawn_container: Node3D
var proj_speed: float = 40.0
var projectile_array: Array

const BALL = preload("uid://dlsk78b4aki17") #Eventually, make a dictionary pointing to specific projectiles with specific IDs. Currently there is only one projectile.

var bullet = preload("uid://ciwb2wf4qn2yy")

func _process(delta):
	if spawn_container == null:
		return
	if spawn_container.get_child_count() == 0:
		return
	else:
		move_projectiles(delta)

@rpc("any_peer", "call_local") # This should likely only be called by the server. The clients should be able to tell the server they want to shoot and then the server shoots.
func shoot_ball(pos, dir, force):
	if !is_multiplayer_authority(): #ensures that only the authority spawns the bullet which is then replicated across all peers with the mulitplayerspawner node
		return
	var new_bullet = bullet.instantiate()
	#new_bullet.source = multiplayer.get_remote_sender_id()
	print(new_bullet.name)
	spawn_container.add_child(new_bullet, true)
	new_bullet.global_position = pos
	new_bullet.global_rotation = dir
	new_bullet.get_child(3).body_entered.connect(on_projectile_collide.bind(new_bullet))
	projectile_array.append(new_bullet.name)


func move_projectiles(delta):
	for i in spawn_container.get_children():
		i.position += i.global_rotation * proj_speed * delta

	# This will be used to move all projectiles in the scene. They likely will not be physics objects anymore. I don't think there's any need. This will replace the functions in shoot ball function
	# This function will also be called in a for loop under the process function

@rpc("authority","call_local")
func on_projectile_collide(body,bullet): # Handles projectile collisions with bodies
	if body == null:
		return
	elif body.is_in_group("Enemies") and is_multiplayer_authority():
		body.take_damage.rpc(1,multiplayer.get_unique_id()) # Sends take damage call to all peers to sync
		print(body)
		bullet.queue_free()
	elif body.is_in_group("Train"):
		bullet.queue_free()
	else:
		bullet.queue_free()
