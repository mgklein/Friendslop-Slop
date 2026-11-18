extends Node3D


@export var train_speed: float = 10.0
@export var acceleration: float = 2.0
@export var deceleration: float = 3.0

var target_train_speed: float = 0.0
var current_train_speed: float = 0.0
var spawn_location: Vector3 = Vector3(-130, 10, -65)

@onready var spawn_container: Node3D = %SpawnContainer
#@onready var timer_target: Timer = %TimerTarget
@onready var track: Path3D = %Track
@onready var track_progress: PathFollow3D = %TrackProgress



func _ready() -> void:
	Global.level = self
	Global.spawn_container = spawn_container
	Global.spawn_location = spawn_location
	
	#timer_target.timeout.connect(spawn_target)
	Global.train_direction_updated.connect(on_train_direction_updated)


func _physics_process(delta: float) -> void:
	move_train(delta)


#func spawn_target():
	#if is_multiplayer_authority() and get_tree().get_node_count_in_group("Targets") < 10:
		#var new_target = TARGET.instantiate()
		#new_target.position = Vector3(randf_range(-25.0, 25.0), 1.0, randf_range(-25.0, 25.0))
		#spawn_container.add_child(new_target, true)


func on_train_direction_updated(dir: int):
	target_train_speed = train_speed * dir


func move_train(delta: float):
	# Smoothly adjust current_speed toward target_speed
	if current_train_speed < target_train_speed:
		current_train_speed = move_toward(current_train_speed, target_train_speed, acceleration * delta)
	else:
		current_train_speed = move_toward(current_train_speed, target_train_speed, deceleration * delta)
	# Move along the path
	if track.curve:
		var total_length = track.curve.get_baked_length()
		track_progress.progress = clamp(track_progress.progress + current_train_speed * delta, 0, total_length)
