extends Node3D

@export var WEAPON_TYPE : Weapons

@onready var weapon_mesh: PackedScene

@onready var camera = %Camera3D

signal projectile_info

# Called when the node enters the scene tree for the first time.
func _ready():
	load_weapon()


func load_weapon():
	weapon_mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation

@rpc("any_peer", "call_local")
func shoot_weapon():
	if !WEAPON_TYPE.shootable:
		return
	var dir = get_shoot_direction()
	projectile_info.emit(global_position + (dir * 1.2), dir, WEAPON_TYPE.projectile_speed)
#Global.shoot_ball.rpc_id(1, pos, shoot_dir, force)

func get_shoot_direction():
	var viewport_rect = get_viewport().get_visible_rect().size
	var raycast_start = camera.project_ray_origin(viewport_rect / 2)
	var raycast_end = raycast_start + camera.project_ray_normal(viewport_rect / 2) * 200
	return (raycast_end - raycast_start).normalized()
	
func _on_player_controller_shoot_weapon():
	shoot_weapon()
