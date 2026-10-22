class_name CameraEffects extends Camera3D

@export_category("References")
@export var player: PlayerController

@export_category("Effects")
@export var enable_tilt: bool = false
@export var enable_fall_kick: bool = false
@export var enable_damage_kick: bool = true
@export var enable_weapon_kick: bool = true
@export var enable_headbob: bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch: float = 0.1 # Degrees
@export var run_roll: float = 0.25 # Degrees
@export var max_pitch: float = 1.0 # Degrees
@export var max_roll: float = 2.5 # Degrees
@export_group("Camera Kick")
@export_subgroup("Fall Kick")
@export var fall_time: float = 0.3
@export_subgroup("Damage Kick")
@export var damage_time: float = 0.3
@export_subgroup("Weapon Kick")
@export var weapon_decay: float = 0.5
@export_subgroup("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch: float = 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll: float = 0.02
@export_range(0.0, 0.04, 0.001) var bob_up: float = 0.005
@export_range(3.0, 10.0, 0.1) var bob_frequency: float = 8.0

var _fall_value: float = 0.0
var _fall_timer: float = 0.0

var _damage_pitch: float = 0.0
var _damage_roll: float = 0.0
var _damage_timer: float = 0.0

var _weapon_kick_angles: Vector3 = Vector3.ZERO

var _step_timer: float = 0.0

func _process(delta: float) -> void:
	calculate_view_offset(delta)


func calculate_view_offset(delta):
	if not player:
		return
	
	_fall_timer -= delta
	_damage_timer -= delta
	
	var velocity = player.velocity
	
	# Headbob Step Timer and Sin Value
	var speed = 10.0 #Vector2(velocity.x, velocity.y).length()
	#if speed > 0.1 and player.is_on_floor():
		#_step_timer += delta * (speed / bob_frequency)
		#_step_timer = fmod(_step_timer, 1.0)
	#else:
		#_step_timer = 0.0
	_step_timer = player.path_controller.progress_ratio * player.num_stop_positions
	var bob_sin = sin(_step_timer * bob_frequency * 2 * PI) * 0.5 # 0.5 reduces magnitude of sine
	
	var angles = Vector3.ZERO
	var offset = Vector3.ZERO
	
	# Camera tilt
	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		
		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x += forward_tilt
		
		var right_dot = velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z -= side_tilt
	
	# Fall kick
	if enable_fall_kick:
		var fall_ratio = max(0.0, _fall_timer / fall_time)
		var fall_kick_amount = fall_ratio * _fall_value
		angles.x -= fall_kick_amount
		offset.y -= fall_kick_amount
	
	# Damage kick
	if enable_damage_kick:
		var damage_ratio = max(0.0, _damage_timer / damage_time)
		#damage_ratio = ease(damage_ratio, -2) # optional ease over time
		angles.x += damage_ratio * _damage_pitch
		angles.z += damage_ratio * _damage_roll
	
	# Weapon kick
	if enable_weapon_kick:
		_weapon_kick_angles = _weapon_kick_angles.move_toward(Vector3.ZERO, weapon_decay * delta)
		angles += _weapon_kick_angles
	
	# Headbob
	if enable_headbob:
		var pitch_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.x -= pitch_delta
		
		var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.z -= roll_delta
		
		var bob_height = bob_sin * bob_up * speed
		offset.y += bob_height
	
	position = offset
	rotation = angles


func add_fall_kick(fall_strength: float): # Left from tutorial. Not fully implemented in Player since not needed
	_fall_value = deg_to_rad(fall_strength)
	_fall_timer = fall_time


func add_damage_kick(pitch: float, roll: float, source: Vector3):
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var direction = global_position.direction_to(source)
	var forward_dot = direction.dot(forward)
	var right_dot = direction.dot(right)
	_damage_pitch = deg_to_rad(pitch) * forward_dot
	_damage_roll = deg_to_rad(roll) * right_dot
	_damage_timer = damage_time


func add_weapon_kick(pitch: float, yaw: float, roll: float):
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))
