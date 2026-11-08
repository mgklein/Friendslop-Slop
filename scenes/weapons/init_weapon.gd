extends Node3D
#Handles all weapon interaction for the individual player or parent

@export var WEAPON_TYPE : Weapons

@onready var weapon_mesh: PackedScene

@onready var camera = %Camera3D

signal projectile_info

# Called when the node enters the scene tree for the first time.
func _ready():
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


func get_shoot_direction(): #Function to determine correct direction to fire projectile
	var viewport_rect = get_viewport().get_visible_rect().size
	var raycast_start = camera.project_ray_origin(viewport_rect / 2)
	var raycast_end = raycast_start + camera.project_ray_normal(viewport_rect / 2) * 200
	return (raycast_end - raycast_start).normalized()
	
func _on_player_controller_shoot_weapon(): #From playercontroller script upon shoot button
	shoot_weapon()
