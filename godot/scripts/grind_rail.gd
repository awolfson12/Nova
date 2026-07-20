class_name NovaGrindRail
extends Node3D

@export var attach_radius := 1.5
@export var boost_acceleration := 9.0
@export var max_grind_speed := 42.0

var curve := Curve3D.new()
var rail_length := 0.0

func configure(points: PackedVector3Array) -> void:
	curve.clear_points()
	for point in points:
		curve.add_point(point)
	rail_length = curve.get_baked_length()
	add_to_group("grind_rails")
	_build_visuals(points)

func nearest_offset(world_position: Vector3) -> float:
	var local_position := to_local(world_position)
	return curve.get_closest_offset(local_position)

func point_at(offset: float) -> Vector3:
	return to_global(curve.sample_baked(clamp(offset, 0.0, rail_length), true))

func tangent_at(offset: float) -> Vector3:
	var a := curve.sample_baked(clamp(offset - 0.08, 0.0, rail_length), true)
	var b := curve.sample_baked(clamp(offset + 0.08, 0.0, rail_length), true)
	return (global_basis * (b - a).normalized()).normalized()

func is_near(world_position: Vector3) -> bool:
	var offset := nearest_offset(world_position)
	return point_at(offset).distance_to(world_position) <= attach_radius

func _build_visuals(points: PackedVector3Array) -> void:
	for index in range(points.size() - 1):
		var start := points[index]
		var finish := points[index + 1]
		var segment := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.09
		cylinder.bottom_radius = 0.09
		cylinder.height = start.distance_to(finish)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("7a55ff")
		material.emission_enabled = true
		material.emission = Color("7a55ff")
		material.emission_energy_multiplier = 2.2
		cylinder.material = material
		segment.mesh = cylinder
		segment.position = (start + finish) * 0.5
		segment.look_at_from_position(segment.position, finish, Vector3.UP)
		segment.rotate_object_local(Vector3.RIGHT, PI * 0.5)
		add_child(segment)

		var detector := Area3D.new()
		detector.collision_layer = 16
		detector.collision_mask = 0
		detector.position = segment.position
		detector.rotation = segment.rotation
		var shape_node := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = attach_radius
		shape.height = maxf(cylinder.height, attach_radius * 2.0)
		shape_node.shape = shape
		detector.add_child(shape_node)
		add_child(detector)
