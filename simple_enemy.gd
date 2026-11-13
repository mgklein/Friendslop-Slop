class_name SimpleEnemy
extends BaseEnemy

@export var follow_speed : float = 3.0


@export var nav_agent: NavigationAgent3D
@export var state_chart: StateChart
@export var health_component: HealthComponent
@export var min_distance_to_target: float
@export var max_distance_to_target: float

@export var shoot_timer : Timer

var target: Node3D
var strafe_position : Vector3

signal shoot_weapon_main

func _ready() -> void:
	super._ready()
	
	#Find Player
	target = get_tree().get_first_node_in_group("Players")
	
	#connect Signals
	health_component.died.connect(_on_died)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	
	move_and_slide()

func on_triggered() -> void:
	state_chart.send_event("toFollow")

func _on_died() -> void:
	queue_free()

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_follow_state_physics_processing(delta: float) -> void:
	if not target:
		return
	
	# Set target position for navigation
	nav_agent.target_position = target.global_position
	
	# Get direction towards target


	var distance_to_target = check_distance()
	if  distance_to_target > (min_distance_to_target*min_distance_to_target) and distance_to_target < (max_distance_to_target * max_distance_to_target):
		state_chart.send_event("toStrafe")
	
	if distance_to_target < (min_distance_to_target * min_distance_to_target):
		state_chart.send_event("toFlee")
	
	moving_to_target(delta)


func moving_to_target(delta):
		# Check if navigation finished
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return
	
	# Get next position in path
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	# Set desired Velocity
	nav_agent.velocity = direction * follow_speed
	
	# Rotate to face move direction
	var towards_target = Vector2(global_position.x,global_position.z).angle_to(Vector2(target.global_position.x,target.global_position.z))
	var target_rotation = rad_to_deg(towards_target)
	#var target_rotation = atan2(direction.x, direction.z)
	#global_rotation.y = lerp_angle(rotation.y,target_rotation.y, 1 * delta)
	self.look_at(target.global_position)
	#global_rotation_degrees.y = target_rotation
	#rotation.x = lerp_angle(rotation.x, target_rotation.x, 5.0 * delta)
	#rotation.y = lerp_angle(rotation.y, target_rotation.y, delta)
	#rotation.z = lerp_angle(rotation.z, target_rotation.z, 5.0 * delta)

func take_damage(damage, source):
	health_component.take_damage(damage)
	pass

func _on_detection_area_body_entered(body):
	if body.is_in_group("Players"):
		on_triggered()

func check_distance():
	var distance_to_target = global_position.distance_squared_to(target.global_position)
	return distance_to_target

func _on_flee_state_physics_processing(delta): # If the enemy gets too close, make the enemy move in opposite direction
	var target_direction = target.global_position.direction_to(global_position)
	var flee_position = global_position + (target_direction * Vector3(randf_range(0.1,3),randf_range(0.1,3),randf_range(0.1,3)) * 5)
	nav_agent.target_position = flee_position
	var target_distance = check_distance()
	if target_distance > (min_distance_to_target * min_distance_to_target):
		state_chart.send_event("toStrafe")
	moving_to_target(delta)


func _on_strafe_state_physics_processing(delta): # When in between min and max range, have enemy constantly moving in that range 
	if nav_agent.is_navigation_finished():
		next_strafe_position()
	var target_distance = check_distance()
	if target_distance < (min_distance_to_target*min_distance_to_target):
		state_chart.send_event("toFlee")
	var target_direction = target.global_position.direction_to(global_position)
	nav_agent.target_position = strafe_position
	moving_to_target(delta)

func next_strafe_position(): # Use this to create the next strafe target position. This is done once and is run a bit until navigation is finished then generates the next strafe position.
	var target_direction = target.global_position.direction_to(global_position)
	strafe_position = target.global_position + ((target_direction + Vector3(randf_range(-.2,.2),randf_range(-.2,.2),randf_range(-.2,.2))) * randf_range(min_distance_to_target,max_distance_to_target))


func _on_strafe_state_entered(): # Generates a strafe position upon entering this state
	next_strafe_position()

func shoot_gun():# use this function to make enemies shoot gun. Likely pass the target rotation to the weapon, down to weapon, back up to this script to pass through to projectile handler
	shoot_weapon_main.emit(target)
	shoot_timer.start()
	print("Enemy shooted")


func _on_follow_state_entered():
	shoot_gun()


func _on_shoot_timer_timeout():
	shoot_gun()


func _on_weapon_projectile_info(projectile_position,projectile_rotation,projectile_speed): #From weapon child node, this is sent to the projectilehandler singleton
	ProjectileHandler.shoot_ball.rpc_id(1, projectile_position,projectile_rotation, projectile_speed)
