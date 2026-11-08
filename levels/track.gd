@tool
extends Path3D

@export var start_station: Station
@export var end_station: Station

# Check this box in the inspector to instantly snap the whole path
@export var regenerate_path: bool = false:
	set(value):
		if value:
			generate_path_curve()
			#snap_points_to_mesh()
			notify_property_list_changed()
			# Refresh CSGPolygon3D children
			for child in get_children():
				if child is CSGPolygon3D:
					child.polygon = child.polygon
@export var num_intermediate_points: int = 3
@export var meander_amplitude: float = 8.0
@export var noise_frequency: float = 0.5


func generate_path_curve():
	if not curve:
		curve = Curve3D.new()
	else:
		curve.clear_points()
	
	if not start_station or not end_station:
		print("Stations not set.")
		return
	
	# Create easy references for intermediate path generation
	var start_point = start_station.entrance_point.global_position
	var end_point = end_station.entrance_point.global_position
	
	# 1. Set up the noise generator for smooth meandering
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = noise_frequency
	noise.seed = randi()
	
	# Calculate perpendicular axes relative to our direct path direction
	var path_vector = end_point - start_point
	var path_dir = path_vector.normalized()
	
	var up_reference = Vector3.UP if abs(path_dir.dot(Vector3.UP)) < 0.9 else Vector3.FORWARD
	var right_axis = path_dir.cross(up_reference).normalized()
	var up_axis = path_dir.cross(right_axis).normalized()
	
	# Add start points
	curve.add_point(start_station.termination_point.global_position)
	curve.add_point(start_point)
	
	# Generate intermediate track points
	for i in range(1, num_intermediate_points + 1):
		var t = float(i) / float(num_intermediate_points + 1)
		var base_pos = start_point.lerp(end_point, t)
		
		# Sample continuous noise for organic drift
		var noise_x = noise.get_noise_1d(t * 10.0)
		var noise_y = noise.get_noise_1d((t * 10.0) + 100.0)
		
		# Push points out horizontally and vertically relative to the forward direction
		var lateral_offset = (right_axis * noise_x * meander_amplitude) + (up_axis * noise_y * meander_amplitude)
		
		# Envelope smoothly tapers the meander effect near start/end points
		var envelope = sin(t * PI) 
		
		var point_pos = base_pos + (lateral_offset * envelope)
		curve.add_point(point_pos)
		
	# Add the end points
	curve.add_point(end_point)
	curve.add_point(end_station.termination_point.global_position)
	
	snap_points_to_mesh()
	
	# Smooth out the tangents using neighboring vectors
	smooth_curve_tangents()

func smooth_curve_tangents() -> void:
	var count = curve.get_point_count()
	for i in range(1, count - 1):
		var prev_pos = curve.get_point_position(i - 1) if i > 0 else curve.get_point_position(i)
		var next_pos = curve.get_point_position(i + 1) if i < count - 1 else curve.get_point_position(i)
		
		# The tangent vector connects the previous point to the next point
		var tangent = (next_pos - prev_pos) * 0.3 # Scale factor determines how wide the curve loops
		
		# In vectors enter the point, out vectors exit it
		curve.set_point_in(i, -tangent)
		curve.set_point_out(i, tangent)


func snap_points_to_mesh():
	var space_state = get_world_3d().direct_space_state
	if not space_state:
		return
		
	# Ensure curve exists
	if not curve:
		return
		
	for i in range(2, curve.point_count - 2):
		var global_pt = global_transform * curve.get_point_position(i)
		
		# Set up a raycast starting above the point, shooting downwards
		var ray_start = global_pt + Vector3(0, 100, 0)
		var ray_end = global_pt + Vector3(0, -500, 0)
		
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Get the contact point and convert it back to the Path3D's local coordinates
			var local_hit_pos = global_transform.inverse() * result.position
			curve.set_point_position(i, local_hit_pos)
			
	print("Path3D successfully snapped to mesh surface!")
