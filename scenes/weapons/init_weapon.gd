@tool
extends Node3D
#Handles all weapon interaction for the individual player or parent

@export var WEAPON_TYPE : Weapons

@onready var weapon_mesh: PackedScene

@export var camera : Camera3D
@export var projectileraycast: RayCast3D

@export var player_node : CharacterBody3D

@export var dispersion : float = 0.05
@export var barrel_length : float = 0
var shoot_direction : Vector3
var animation_player: AnimationPlayer

signal projectile_info

# Called when the node enters the scene tree for the first time.
func _ready():
	load_weapon()
	if player_node == null:
		return
	if player_node.is_in_group("Players"):
		print("parent is player")
		camera = %Camera3D


func load_weapon(): #function to initialize the weapon. Call this when switching or starting
	weapon_mesh = WEAPON_TYPE.mesh
	var weapon_model = weapon_mesh.instantiate()
	add_child(weapon_model,true)
	weapon_model.position = WEAPON_TYPE.position
	weapon_model.rotation_degrees = WEAPON_TYPE.rotation
	var num_childs = weapon_model.get_child_count()
	animation_player = weapon_model.get_child(num_childs-1) # Selects the last node as the animationplayer. Ensure the animation player is placed as the last node in the weapon model scene. Also ensure that the animation is named "shoot"


@rpc("any_peer","call_local")
func play_shoot_animation():
	animation_player.play("shoot")

@rpc("any_peer", "call_local")
func shoot_weapon():#Function to shoot the weapon
	if !WEAPON_TYPE.shootable:
		return
	var dir = get_shoot_direction()
	projectile_info.emit(global_position + (dir * 1.2), dir, WEAPON_TYPE.projectile_speed) #send signal back to playercontroller with information on the projectile
	if animation_player != null:
		play_shoot_animation.rpc()



func get_shoot_direction(): #Function to determine correct direction to fire projectile. TO DO change this function to just take the raycast from the gun but this requires the gun moving with camera.
	# This will eventually just follow the raycast node in each weapon for the shooting position and direction of the bullet making this entire function obsolete. 
	if player_node == null:
		return shoot_direction
	if player_node.is_in_group("Players"): # Or maybe we can somehow sync a raycast from the viewport/camera to the raycast of the weapon. Then there would still be a need for the way players handle weapon aiming and the way enemies handle it
		var viewport_rect = get_viewport().get_visible_rect().size
		var raycast_start = camera.project_ray_origin(viewport_rect / 2)
		var raycast_end = raycast_start + camera.project_ray_normal(viewport_rect / 2) * 200
		return (raycast_end - raycast_start).normalized()
	else:
		return shoot_direction

func _on_player_controller_shoot_weapon(): #From playercontroller script upon shoot button
	shoot_weapon()

func add_dispersion():
	shoot_direction = (shoot_direction + Vector3(randf_range(-dispersion,dispersion), randf_range(-dispersion,dispersion), randf_range(-dispersion,dispersion))).normalized()


func _on_simple_enemy_shoot_weapon_main(target):
	shoot_direction = (target.global_position - global_position).normalized() # Likely should be moved into the get_shoot_direction function
	add_dispersion()
	shoot_weapon()
