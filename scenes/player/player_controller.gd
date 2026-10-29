class_name PlayerController
extends CharacterBody3D


@export var debug: bool = false
@export_category("References")
@export var state_chart: StateChart
@export var standing_collision: CollisionShape3D
@export var crouching_collision: CollisionShape3D
@export var crouch_check: ShapeCast3D
@export var interaction_raycast: RayCast3D
@export_category("Movement Settings")
@export_group("Easing")
@export var acceleration: float = 0.2
@export var deceleration: float = 0.5
@export_group("Speed")
@export var default_speed: float = 7.0
@export var sprint_speed: float = 3.0
@export var crouch_speed: float = -5.0
@export_category("Jump Settings")
@export var jump_velocity: float = 7.0


var _input_dir: Vector2 = Vector2.ZERO
var _movement_velocity: Vector3 = Vector3.ZERO
var sprint_modifier: float = 0.0
var crouch_modifier: float = 0.0
var speed: float = 0.0

@onready var camera: Camera3D = %Camera3D
@onready var camera_controller: Node3D = %CameraController
@onready var nameplate: Label3D = $Nameplate
@onready var hit_marker: Label = %HitMarker

@onready var sound_hit: AudioStreamPlayer = %SoundHit
@onready var sound_ping: AudioStreamPlayer = %SoundPing


var immobile := false


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))


func _ready() -> void:
	add_to_group("Players")
	nameplate.text = name
	hit_marker.hide()
	
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		return
	# Now guaranteed to be multiplayer authority

	Global.game_controller.player_controller = self
	if Global.username: nameplate.text = Global.username
	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.clipboard_set(Network.tube_client.session_id)


func _process(_delta: float) -> void:
	if immobile:
		return
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("train_forward"):
		rpc("sync_train_direction", 1)
	if Input.is_action_just_pressed("train_reverse"):
		rpc("sync_train_direction", -1)
	if Input.is_action_just_released("train_forward"):
		rpc("sync_train_direction", 0)
	if Input.is_action_just_released("train_reverse"):
		rpc("sync_train_direction", 0)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var speed_modifier = sprint_modifier + crouch_modifier
	speed = default_speed + speed_modifier

	_input_dir = Input.get_vector("left", "right", "forward", "backward")
	var current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	var direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	
	if immobile:
		direction = Vector3.ZERO
	
	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * speed, acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)
	
	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	velocity = _movement_velocity
	
	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	move_and_slide()


func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)


func sprint() -> void:
	sprint_modifier = sprint_speed


func walk() -> void:
	sprint_modifier = 0.0


func stand() -> void:
	crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true


func crouch() -> void:
	crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false


func jump() -> void:
	velocity.y += jump_velocity


func shoot():
	var force = 100
	var pos = global_position
	var shoot_dir = get_shoot_direction()
	Global.shoot_ball.rpc_id(1, pos, shoot_dir, force)


func get_shoot_direction():
	var viewport_rect = get_viewport().get_visible_rect().size
	var raycast_start = camera.project_ray_origin(viewport_rect / 2)
	var raycast_end = raycast_start + camera.project_ray_normal(viewport_rect / 2) * 200
	return (raycast_end - raycast_start).normalized()


@rpc("any_peer", "call_local")
func register_hit(is_dead = false):
	if is_dead:
		sound_ping.play()
	else:
		sound_hit.play()
	
	hit_marker.show()
	await get_tree().create_timer(0.2).timeout
	hit_marker.hide()


@rpc("any_peer", "call_local", "reliable")
func sync_train_direction(dir: int):
	Global.train_direction_updated.emit(dir)
