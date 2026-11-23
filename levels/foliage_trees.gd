@tool
extends MultiMeshInstance3D

@export_category("Terrain Managers and Track")
@export var terrain_manager: Node3D # Assign your LowPolyTerrainManager here
@export var water_terrain_manager: Node3D
@export var track: Path3D

@export_category("Populate Margins")
@export var water_margin: float = 1.0
@export var track_margin: float = 10.0

@export_category("Populate Parameters")
@export var scatter_mesh: Mesh
@export var instance_count: int = 5000
@export var area_size: Vector2 = Vector2(100.0, 100.0)
@export var min_scale: float = 0.8
@export var max_scale: float = 1.4

@export var populate: bool = false:
	set(value):
		if value:
			if terrain_manager and scatter_mesh and track:
				populate_multimesh()


#func _ready() -> void:
	#if not terrain_manager or not scatter_mesh:
		#push_warning("Assign both terrain_manager and scatter_mesh.")
		#return
	#populate_multimesh()

func populate_multimesh() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = scatter_mesh
	mm.instance_count = instance_count

	var placed := 0
	var attempts := 0
	var max_attempts := instance_count * 3

	var curve: Curve3D = track.curve

	while placed < instance_count and attempts < max_attempts:
		attempts += 1
		
		# Pick a random world XZ position relative to this node
		var rx := randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var rz := randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		var world_x := global_position.x + rx
		var world_z := global_position.z + rz

		# Ensure the point falls within active terrain bounds
		if not terrain_manager.is_inside_terrain(world_x, world_z):
			continue

		# O(1) height lookup directly from the height matrix
		var world_y: float = terrain_manager.get_height_at_world_coords(world_x, world_z)
		var water_y: float = water_terrain_manager.get_height_at_world_coords(world_x, world_z)
		var world_pos := Vector3(world_x, world_y, world_z)
		
		if abs(water_y - world_y) > water_margin: # don't generate in water
			continue
		
		# Check if chosen point is close to track
		var local_point: Vector3 = track.to_local(world_pos)
		var offset: float = curve.get_closest_offset(local_point)
		var closest_local_point: Vector3 = curve.sample_baked(offset)
		var distance_to_curve: float = local_point.distance_to(closest_local_point)
		
		if distance_to_curve < track_margin:
			continue

		# Build transform with random Y rotation and uniform scale
		var tree_basis := Basis.IDENTITY.rotated(Vector3.UP, randf() * TAU)
		tree_basis = tree_basis.scaled(Vector3.ONE * randf_range(min_scale, max_scale))

		# Convert world position to local space of the MultiMeshInstance3D
		var local_pos := to_local(world_pos)
		mm.set_instance_transform(placed, Transform3D(tree_basis, local_pos))
		placed += 1

	# Only render instances that landed inside valid terrain bounds
	mm.visible_instance_count = placed
	multimesh = mm
