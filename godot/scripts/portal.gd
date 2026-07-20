class_name NovaPortal
extends Area3D

const PORTAL_SIZE := Vector2(1.45, 2.25)
const EXIT_OFFSET := 1.25

var partner: NovaPortal
var portal_color := Color("38a9ff")
var teleport_enabled := true
var view_camera: Camera3D
var viewport: SubViewport
var surface_material: StandardMaterial3D
var tracked_bodies: Dictionary = {}

func configure(color: Color) -> void:
	portal_color = color
	_build_visuals()

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2 | 8
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	_update_portal_camera()
	_check_crossings()

func _build_visuals() -> void:
	for child in get_children():
		child.queue_free()

	viewport = SubViewport.new()
	viewport.name = "PortalViewport"
	viewport.size = Vector2i(640, 960)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	viewport.world_3d = get_viewport().world_3d
	add_child(viewport)

	view_camera = Camera3D.new()
	view_camera.name = "PortalCamera"
	view_camera.current = true
	view_camera.fov = 80.0
	view_camera.near = 0.05
	viewport.add_child(view_camera)

	var frame := MeshInstance3D.new()
	frame.name = "Frame"
	var frame_mesh := TorusMesh.new()
	frame_mesh.inner_radius = 0.68
	frame_mesh.outer_radius = 0.82
	frame_mesh.rings = 32
	frame_mesh.ring_segments = 16
	var frame_material := StandardMaterial3D.new()
	frame_material.albedo_color = portal_color
	frame_material.emission_enabled = true
	frame_material.emission = portal_color
	frame_material.emission_energy_multiplier = 4.0
	frame_mesh.material = frame_material
	frame.mesh = frame_mesh
	frame.scale = Vector3(1.0, 1.55, 1.0)
	frame.rotation_degrees.x = 90.0
	add_child(frame)

	var surface := MeshInstance3D.new()
	surface.name = "Surface"
	var surface_mesh := QuadMesh.new()
	surface_mesh.size = PORTAL_SIZE
	surface_material = StandardMaterial3D.new()
	surface_material.albedo_texture = viewport.get_texture()
	surface_material.emission_enabled = true
	surface_material.emission_texture = viewport.get_texture()
	surface_material.emission_energy_multiplier = 0.9
	surface_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	surface_mesh.material = surface_material
	surface.mesh = surface_mesh
	add_child(surface)

	var collider := CollisionShape3D.new()
	collider.name = "Trigger"
	var shape := BoxShape3D.new()
	shape.size = Vector3(PORTAL_SIZE.x, PORTAL_SIZE.y, 0.45)
	collider.shape = shape
	collider.position.z = 0.08
	add_child(collider)

func _update_portal_camera() -> void:
	if partner == null or not is_instance_valid(partner) or view_camera == null:
		return
	var source_camera := get_viewport().get_camera_3d()
	if source_camera == null or source_camera == view_camera or source_camera == partner.view_camera:
		return
	var local_transform := global_transform.affine_inverse() * source_camera.global_transform
	var flip := Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	view_camera.global_transform = partner.global_transform * flip * local_transform
	view_camera.fov = source_camera.fov

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		tracked_bodies[body.get_instance_id()] = {
			"body": body,
			"last_z": to_local(body.global_position).z
		}

func _on_body_exited(body: Node3D) -> void:
	tracked_bodies.erase(body.get_instance_id())

func _check_crossings() -> void:
	if not teleport_enabled or partner == null or not is_instance_valid(partner):
		return
	for id in tracked_bodies.keys():
		var entry: Dictionary = tracked_bodies[id]
		var body := entry.get("body") as Node3D
		if body == null or not is_instance_valid(body):
			tracked_bodies.erase(id)
			continue
		if body.has_method("can_use_portal") and not body.can_use_portal():
			entry["last_z"] = to_local(body.global_position).z
			tracked_bodies[id] = entry
			continue
		var local_position := to_local(body.global_position)
		var last_z: float = entry.get("last_z", local_position.z)
		if last_z > 0.0 and local_position.z <= 0.0:
			_teleport_body(body)
			tracked_bodies.erase(id)
			continue
		entry["last_z"] = local_position.z
		tracked_bodies[id] = entry

func _teleport_body(body: Node3D) -> void:
	var flip := Basis(Vector3.UP, PI)
	var relative_basis := global_basis.inverse() * body.global_basis
	body.global_basis = partner.global_basis * flip * relative_basis
	var local_position := to_local(body.global_position)
	local_position.z = 0.0
	var mapped_local := flip * local_position
	body.global_position = partner.to_global(mapped_local) + (-partner.global_basis.z * EXIT_OFFSET)

	if body is CharacterBody3D:
		var character := body as CharacterBody3D
		var local_velocity := global_basis.inverse() * character.velocity
		character.velocity = partner.global_basis * (flip * local_velocity)
	elif body is RigidBody3D:
		var rigid := body as RigidBody3D
		var local_linear := global_basis.inverse() * rigid.linear_velocity
		var local_angular := global_basis.inverse() * rigid.angular_velocity
		rigid.linear_velocity = partner.global_basis * (flip * local_linear)
		rigid.angular_velocity = partner.global_basis * (flip * local_angular)

	if body.has_method("mark_portal_used"):
		body.mark_portal_used()
