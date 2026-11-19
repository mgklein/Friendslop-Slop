extends Node3D
#Handles all weapon interaction for the individual player or parent

@export var WEAPON_TYPE : Weapons

@onready var weapon_mesh: PackedScene

@export var camera : Camera3D
@export var projectileraycast: RayCast3D

@export var player_node : CharacterBody3D

var shoot_direction : Vector3

signal projectile_info

# Called when the node enters the scene tree for the first time.
func _ready():
	if player_node.is_in_group("Players"):
		print("parent is player")
		camera = %Camera3D
	load_weapon()


func load_weapon(): #function to initialize the weapon. Call this when switching or starting
	weapon_mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation

@rpc("any_peer", "call_local")
func shoot_weapon():#Function to shoot the weapon
	if !WEAPON_TYPE.shootable:
		return
	var dir = get_shoot_direction()
	projectile_info.emit(global_position + (dir * 1.2), dir, WEAPON_TYPE.projectile_speed) #send signal back to playercontroller with information on the projectile
	print(dir)


func get_shoot_direction(): #Function to determine correct direction to fire projectile. TO DO change this function to just take the raycast from the gun but this requires the gun moving with camera.
	# This will eventually just follow the raycast node in each weapon for the shooting position and direction of the bullet making this entire function obsolete. 
	if player_node.is_in_group("Players"): # Or maybe we can somehow sync a raycast from the viewport/camera to the raycast of the weapon. Then there would still be a need for the way players handle weapon aiming and the way enemies handle it
		var viewport_rect = get_viewport().get_visible_rect().size
		var raycast_start = camera.project_ray_origin(viewport_rect / 2)
		var raycast_end = raycast_start + camera.project_ray_normal(viewport_rect / 2) * 200
		print("player shoot")
		return (raycast_end - raycast_start).normalized()
	else:
		print("not player shoot?")
		return shoot_direction

func _on_player_controller_shoot_weapon(): #From playercontroller script upon shoot button
	shoot_weapon()


func _on_simple_enemy_shoot_weapon_main(target):
	shoot_direction = (target.global_position - global_position).normalized() # Likely should be moved into the get_shoot_direction function
	shoot_weapon()
