extends Node3D

const PLAYER_SCRIPT := preload("res://scripts/player.gd")
const PORTAL_MANAGER_SCRIPT := preload("res://scripts/portal_manager.gd")

var player: CharacterBody3D

func _ready() -> void:
	_build_environment()
	_build_course()
	_spawn_player()
	_build_portal_manager()
	_spawn_physics_tests()
	_build_hud()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("101522")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("8aa0c8")
	environment.ambient_light_energy = 0.55
	world.environment = environment
	add_child(world)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_energy = 1.4
	light.shadow_enabled = true
	add_child(light)

func _build_course() -> void:
	_add_box("Floor", Vector3(0, -0.5, 0), Vector3(54, 1, 54), Color("263247"), Vector3.ZERO, true)
	_add_box("StartRamp", Vector3(0, 0.4, -10), Vector3(8, 1, 12), Color("38506f"), Vector3(-8, 0, 0), true)
	_add_box("LeftWall", Vector3(-8, 3, 2), Vector3(1, 6, 18), Color("6c7f96"), Vector3.ZERO, true)
	_add_box("RightWall", Vector3(8, 3, 2), Vector3(1, 6, 18), Color("6c7f96"), Vector3.ZERO, true)
	_add_box("Landing", Vector3(0, 2, 14), Vector3(10, 1, 8), Color("7f91a7"), Vector3.ZERO, true)
	_add_box("Step1", Vector3(-5, 1, 23), Vector3(5, 2, 5), Color("354c69"), Vector3.ZERO, false)
	_add_box("Step2", Vector3(2, 2.5, 23), Vector3(5, 5, 5), Color("76889e"), Vector3.ZERO, true)
	_add_box("Step3", Vector3(9, 4, 23), Vector3(5, 8, 5), Color("46698d"), Vector3.ZERO, false)
	_add_box("HighRun", Vector3(16, 7, 12), Vector3(2, 14, 18), Color("71859d"), Vector3.ZERO, true)
	_add_box("Finish", Vector3(16, 9, -2), Vector3(8, 1, 8), Color("8ba0b8"), Vector3.ZERO, true)
	_add_box("PortalTower", Vector3(-17, 5, 12), Vector3(5, 10, 5), Color("8799ad"), Vector3.ZERO, true)
	_add_box("LaunchCeiling", Vector3(-17, 11, 2), Vector3(10, 1, 14), Color("8799ad"), Vector3.ZERO, true)
	_add_box("PhysicsDeck", Vector3(-17, 2.5, -12), Vector3(10, 1, 8), Color("7f91a7"), Vector3.ZERO, true)
	_add_box("BoundaryNorth", Vector3(0, 4, -27), Vector3(54, 8, 1), Color("1d2737"), Vector3.ZERO, false)
	_add_box("BoundarySouth", Vector3(0, 4, 27), Vector3(54, 8, 1), Color("1d2737"), Vector3.ZERO, false)
	_add_box("BoundaryWest", Vector3(-27, 4, 0), Vector3(1, 8, 54), Color("1d2737"), Vector3.ZERO, false)
	_add_box("BoundaryEast", Vector3(27, 4, 0), Vector3(1, 8, 54), Color("1d2737"), Vector3.ZERO, false)

func _add_box(label: String, position: Vector3, size: Vector3, color: Color, rotation_deg := Vector3.ZERO, portalable := false) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position
	body.rotation_degrees = rotation_deg
	if portalable:
		body.add_to_group("portalable")

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if portalable:
		material.metallic = 0.18
	box_mesh.material = material
	mesh.mesh = box_mesh
	body.add_child(mesh)

	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _spawn_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 2, -20)
	player.collision_layer = 2
	player.collision_mask = 1
	player.set_script(PLAYER_SCRIPT)

	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	collider.shape = capsule
	player.add_child(collider)

	var head := Node3D.new()
	head.name = "Head"
	head.position.y = 0.72
	player.add_child(head)

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	camera.fov = 80.0
	head.add_child(camera)
	add_child(player)

func _build_portal_manager() -> void:
	var manager := Node3D.new()
	manager.name = "PortalManager"
	manager.set_script(PORTAL_MANAGER_SCRIPT)
	add_child(manager)
	manager.setup(player)

func _spawn_physics_tests() -> void:
	for index in range(5):
		var body := RigidBody3D.new()
		body.name = "PortalTestBody%d" % index
		body.position = Vector3(-19.0 + index, 4.2 + index * 0.45, -12.0)
		body.collision_layer = 8
		body.collision_mask = 1
		body.mass = 0.8

		var mesh := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.32
		sphere.height = 0.64
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("d9f2ff")
		material.emission_enabled = true
		material.emission = Color("4cc9ff")
		material.emission_energy_multiplier = 0.8
		sphere.material = material
		mesh.mesh = sphere
		body.add_child(mesh)

		var collider := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 0.32
		collider.shape = shape
		body.add_child(collider)
		add_child(body)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "CanvasLayer"
	var label := Label.new()
	label.name = "SpeedLabel"
	label.position = Vector2(24, 20)
	label.add_theme_font_size_override("font_size", 24)
	label.text = "NOVA // COMPLETE PORTAL LAB\nLMB blue  RMB orange  glowing spheres test physics traversal"
	layer.add_child(label)

	var crosshair := Label.new()
	crosshair.position = Vector2(635, 345)
	crosshair.add_theme_font_size_override("font_size", 24)
	crosshair.text = "+"
	layer.add_child(crosshair)
	add_child(layer)
