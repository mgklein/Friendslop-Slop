@tool
extends Path3D

# Check this box in the inspector to instantly snap the whole path
@export var snap_path_now: bool = false:
	set(value):
		if value:
			snap_points_to_mesh()
			notify_property_list_changed()

func snap_points_to_mesh():
	var space_state = get_world_3d().direct_space_state
	if not space_state:
		return
		
	# Ensure curve exists
	if not curve:
		return
		
	for i in range(curve.point_count):
		var global_pt = global_transform * curve.get_point_position(i)
		
		# Set up a raycast starting above the point, shooting downwards
		var ray_start = global_pt + Vector3(0, 10, 0)
		var ray_end = global_pt + Vector3(0, -50, 0)
		
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Get the contact point and convert it back to the Path3D's local coordinates
			var local_hit_pos = global_transform.inverse() * result.position
			curve.set_point_position(i, local_hit_pos)
			
	print("Path3D successfully snapped to mesh surface!")
