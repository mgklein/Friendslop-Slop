@tool
extends Path3D


@export var regenerate_path := false:
	set(value):
		if value:
			generate_snapped_path()
			notify_property_list_changed()
@export var generated_path: Path3D
@export var sample_spacing := 1.0


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


func generate_snapped_path():
	if generated_path == null:
		push_error("Generated Path not assigned.")
		return
	if curve == null:
		return
	var space_state = get_world_3d().direct_space_state
	if space_state == null:
		return
	curve.bake_interval = sample_spacing
	var baked_points = curve.get_baked_points()
	var new_curve := Curve3D.new()
	for point in baked_points:
		var global_point = global_transform * point
		var query = PhysicsRayQueryParameters3D.create(
			global_point + Vector3.UP * 100.0,
			global_point + Vector3.DOWN * 500.0
		)
		query.collision_mask = 1 << 1
		var result = space_state.intersect_ray(query)
		if result:
			var local_hit = generated_path.to_local(result.position)
			new_curve.add_point(local_hit)
		else:
			new_curve.add_point(generated_path.to_local(global_point))
	generated_path.curve = new_curve
	smooth_generated_curve(generated_path.curve)


func smooth_generated_curve(c: Curve3D):
	var count := c.point_count
	for i in range(1, count - 1):
		var prev = c.get_point_position(i - 1)
		var next = c.get_point_position(i + 1)
		var tangent = (next - prev) * 0.3
		c.set_point_in(i, -tangent)
		c.set_point_out(i, tangent)
