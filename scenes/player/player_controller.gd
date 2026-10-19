class_name PlayerController
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var sensitivity: float = 0.002

@onready var camera_3d: Camera3D = %Camera3D
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
	camera_3d.current = true
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

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if immobile:
		direction = Vector3.ZERO
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)


func shoot():
	var force = 100
	var pos = global_position
	var shoot_dir = get_shoot_direction()
	Global.shoot_ball.rpc_id(1, pos, shoot_dir, force)


func get_shoot_direction():
	var viewport_rect = get_viewport().get_visible_rect().size
	var raycast_start = camera_3d.project_ray_origin(viewport_rect / 2)
	var raycast_end = raycast_start + camera_3d.project_ray_normal(viewport_rect / 2) * 200
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
