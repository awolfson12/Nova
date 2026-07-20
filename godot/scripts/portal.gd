class_name NovaPortal
extends Area3D

var partner: NovaPortal
var portal_color := Color("38a9ff")
var teleport_enabled := true

func configure(color: Color) -> void:
	portal_color = color
	_build_visuals()

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _build_visuals() -> void:
	for child in get_children():
		child.queue_free()

	var frame := MeshInstance3D.new()
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
	var surface_mesh := QuadMesh.new()
	surface_mesh.size = Vector2(1.45, 2.25)
	var surface_material := StandardMaterial3D.new()
	surface_material.albedo_color = Color(portal_color, 0.33)
	surface_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	surface_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	surface_mesh.material = surface_material
	surface.mesh = surface_mesh
	add_child(surface)

	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.45, 2.25, 0.35)
	collider.shape = shape
	collider.position.z = 0.12
	add_child(collider)

func _on_body_entered(body: Node3D) -> void:
	if not teleport_enabled or partner == null or not is_instance_valid(partner):
		return
	if not body is CharacterBody3D:
		return
	if body.has_method("can_use_portal") and not body.can_use_portal():
		return

	var character := body as CharacterBody3D
	var local_velocity := global_basis.inverse() * character.velocity
	var mapped_velocity := partner.global_basis * Vector3(-local_velocity.x, local_velocity.y, -local_velocity.z)
	var exit_forward := -partner.global_basis.z
	character.global_position = partner.global_position + exit_forward * 1.6
	character.velocity = mapped_velocity
	character.global_basis = Basis(Vector3.UP, partner.global_rotation.y)
	if character.has_method("mark_portal_used"):
		character.mark_portal_used()
