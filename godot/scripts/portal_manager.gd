extends Node3D

const PORTAL_SCRIPT := preload("res://scripts/portal.gd")

var blue_portal: NovaPortal
var orange_portal: NovaPortal
var player: CharacterBody3D
var camera: Camera3D

func setup(target_player: CharacterBody3D) -> void:
	player = target_player
	camera = player.get_node("Head/Camera3D")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_place_portal(true)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_place_portal(false)

func _place_portal(is_blue: bool) -> void:
	if camera == null:
		return
	var from := camera.global_position
	var to := from + -camera.global_basis.z * 80.0
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.exclude = [player]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider := hit.get("collider") as Node
	if collider == null or not collider.is_in_group("portalable"):
		return

	var normal: Vector3 = hit.get("normal").normalized()
	var position: Vector3 = hit.get("position") + normal * 0.035
	var up := Vector3.UP
	if absf(normal.dot(up)) > 0.95:
		up = Vector3.FORWARD
	var portal_basis := Basis.looking_at(normal, up)

	var portal: NovaPortal = blue_portal if is_blue else orange_portal
	if portal == null or not is_instance_valid(portal):
		portal = Area3D.new()
		portal.set_script(PORTAL_SCRIPT)
		add_child(portal)
		portal.configure(Color("38a9ff") if is_blue else Color("ff8a2a"))
		if is_blue:
			blue_portal = portal
		else:
			orange_portal = portal

	portal.global_transform = Transform3D(portal_basis, position)
	_link_portals()

func _link_portals() -> void:
	if blue_portal != null and orange_portal != null:
		blue_portal.partner = orange_portal
		orange_portal.partner = blue_portal
