extends Node3D

const PLAYER_SCRIPT := preload("res://scripts/player.gd")

func _ready() -> void:
	_build_environment()
	_build_course()
	_spawn_player()
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
	_add_box("Floor", Vector3(0, -0.5, 0), Vector3(54, 1, 54), Color("263247"))
	_add_box("StartRamp", Vector3(0, 0.4, -10), Vector3(8, 1, 12), Color("38506f"), Vector3(-8, 0, 0))
	_add_box("LeftWall", Vector3(-8, 3, 2), Vector3(1, 6, 18), Color("314766"))
	_add_box("RightWall", Vector3(8, 3, 2), Vector3(1, 6, 18), Color("314766"))
	_add_box("Landing", Vector3(0, 2, 14), Vector3(10, 1, 8), Color("45698f"))
	_add_box("Step1", Vector3(-5, 1, 23), Vector3(5, 2, 5), Color("354c69"))
	_add_box("Step2", Vector3(2, 2.5, 23), Vector3(5, 5, 5), Color("3d5878"))
	_add_box("Step3", Vector3(9, 4, 23), Vector3(5, 8, 5), Color("46698d"))
	_add_box("HighRun", Vector3(16, 7, 12), Vector3(2, 14, 18), Color("385473"))
	_add_box("Finish", Vector3(16, 9, -2), Vector3(8, 1, 8), Color("4c7daa"))
	_add_box("BoundaryNorth", Vector3(0, 4, -27), Vector3(54, 8, 1), Color("1d2737"))
	_add_box("BoundarySouth", Vector3(0, 4, 27), Vector3(54, 8, 1), Color("1d2737"))
	_add_box("BoundaryWest", Vector3(-27, 4, 0), Vector3(1, 8, 54), Color("1d2737"))
	_add_box("BoundaryEast", Vector3(27, 4, 0), Vector3(1, 8, 54), Color("1d2737"))

func _add_box(label: String, position: Vector3, size: Vector3, color: Color, rotation_deg := Vector3.ZERO) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position
	body.rotation_degrees = rotation_deg

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
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
	var player := CharacterBody3D.new()
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

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	var label := Label.new()
	label.name = "SpeedLabel"
	label.position = Vector2(24, 20)
	label.add_theme_font_size_override("font_size", 24)
	label.text = "NOVA // MOVEMENT LAB\nWASD move  SPACE jump  SHIFT dash  C/CTRL slide  R restart"
	layer.add_child(label)
	add_child(layer)
