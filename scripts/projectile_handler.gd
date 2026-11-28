extends Node

#This will handle all projectiles in the scene.

@onready var root_node = get_tree()

var game_controller: GameController
var level: Node3D
var spawn_container: Node3D
var proj_speed: float = 40.0
var projectile_array: Array

var projectile_resource_paths: Array

var projectile_dictionary : Dictionary = {}

const BALL = preload("uid://dlsk78b4aki17") #Eventually, make a dictionary pointing to specific projectiles with specific IDs. Currently there is only one projectile.

var bullet = preload("uid://ciwb2wf4qn2yy")

func _ready():
	load_projectile_resources()
	if is_multiplayer_authority():
		return
	ProjectileHandler.catch_up_client.rpc_id(1)


func _process(delta):
	if spawn_container == null:
		return
	if spawn_container.get_child_count() == 0:
		return
	else:
		move_projectiles(delta)

func load_projectile_resources(): # This loads all resources in the assets/weapons folder which are the projectile resources
	var weapon_folder_path : String = "res://assets/weapons/"
	var weapons_folder = ResourceLoader.list_directory(weapon_folder_path)
	for i in weapons_folder:
		var subfiles = ResourceLoader.list_directory(weapon_folder_path + i)
		for x in subfiles:
			if x.ends_with("tres"):
				projectile_resource_paths.append(weapon_folder_path + i + x)
	for i in projectile_resource_paths:
		var proj_resource = ResourceLoader.load(i)
		projectile_dictionary.get_or_add(proj_resource.name,proj_resource.projectile_scene)


@rpc("any_peer","call_remote")
func catch_up_client():
	var client = multiplayer.get_remote_sender_id()
	ProjectileHandler.catch_up_self.rpc_id(client,projectile_array)

@rpc("authority","call_local")
func catch_up_self(server_array : Array):
	for i in server_array:
		self.spawn_projectile(server_array[i][1],server_array[i][2],0)
	pass

@rpc("any_peer", "call_local") # This should likely only be called by the server. The clients should be able to tell the server they want to shoot and then the server shoots.
func shoot_ball(pos, dir, force):
	if !is_multiplayer_authority(): #ensures that only the authority spawns the bullet which is then replicated across all peers with the mulitplayerspawner node
		return
	spawn_projectile(pos, dir, force)

func spawn_projectile(pos, dir, force):
	var new_bullet = bullet.instantiate()
	#new_bullet.source = multiplayer.get_remote_sender_id()
	spawn_container.add_child(new_bullet, true)
	new_bullet.global_position = pos
	new_bullet.global_rotation = dir
	new_bullet.get_child(3).body_entered.connect(on_projectile_collide.bind(new_bullet))
	projectile_array.append([new_bullet.name,new_bullet.global_position,new_bullet.global_rotation])

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
		bullet.queue_free()
	elif body.is_in_group("Train"):
		bullet.queue_free()
	else:
		bullet.queue_free()
