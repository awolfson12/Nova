extends CharacterBody3D

@export var walk_speed := 10.0
@export var sprint_speed := 17.0
@export var ground_acceleration := 46.0
@export var air_acceleration := 13.0
@export var ground_friction := 12.0
@export var jump_velocity := 8.5
@export var gravity := 24.0
@export var dash_impulse := 15.0
@export var dash_cooldown := 0.85
@export var mouse_sensitivity := 0.0022
@export var wall_run_gravity := 5.0
@export var wall_jump_push := 9.0

var head: Node3D
var camera: Camera3D
var dash_timer := 0.0
var spawn_position := Vector3.ZERO
var is_sliding := false
var current_speed := 0.0

func _ready() -> void:
	head = get_node("Head")
	camera = head.get_node("Camera3D")
	spawn_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-88), deg_to_rad(88))
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	dash_timer = maxf(0.0, dash_timer - delta)
	if Input.is_action_just_pressed("restart") or global_position.y < -12.0:
		_restart()

	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_direction := (transform.basis * Vector3(input_2d.x, 0, input_2d.y)).normalized()
	is_sliding = Input.is_action_pressed("slide") and is_on_floor() and Vector2(velocity.x, velocity.z).length() > 8.0

	if is_on_floor():
		_apply_ground_movement(wish_direction, delta)
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		_apply_air_movement(wish_direction, delta)
		_apply_vertical_physics(delta)

	if Input.is_action_just_pressed("dash") and dash_timer <= 0.0:
		var dash_direction := wish_direction
		if dash_direction == Vector3.ZERO:
			dash_direction = -transform.basis.z
		velocity += dash_direction.normalized() * dash_impulse
		dash_timer = dash_cooldown

	move_and_slide()
	_update_camera(delta)
	_update_hud()

func _apply_ground_movement(wish_direction: Vector3, delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if wish_direction == Vector3.ZERO:
		horizontal = horizontal.move_toward(Vector3.ZERO, ground_friction * delta)
	else:
		var target_speed := sprint_speed
		if is_sliding:
			target_speed = maxf(horizontal.length(), sprint_speed * 1.15)
		var target := wish_direction * target_speed
		var accel := ground_acceleration * (0.35 if is_sliding else 1.0)
		horizontal = horizontal.move_toward(target, accel * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if is_sliding:
		velocity += -transform.basis.z * 5.0 * delta

func _apply_air_movement(wish_direction: Vector3, delta: float) -> void:
	if wish_direction == Vector3.ZERO:
		return
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	var target := wish_direction * sprint_speed
	horizontal = horizontal.move_toward(target, air_acceleration * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

func _apply_vertical_physics(delta: float) -> void:
	var wall_running := is_on_wall() and velocity.y <= 2.0 and Vector2(velocity.x, velocity.z).length() > 8.0
	if wall_running:
		velocity.y -= wall_run_gravity * delta
		if Input.is_action_just_pressed("jump"):
			var normal := get_wall_normal()
			velocity += normal * wall_jump_push
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta

func _update_camera(delta: float) -> void:
	current_speed = Vector2(velocity.x, velocity.z).length()
	var speed_ratio := clamp(current_speed / 28.0, 0.0, 1.0)
	camera.fov = lerpf(camera.fov, 80.0 + speed_ratio * 18.0, 7.5 * delta)
	var target_height := 0.25 if is_sliding else 0.72
	head.position.y = lerpf(head.position.y, target_height, 12.0 * delta)
	var target_roll := -Input.get_axis("move_left", "move_right") * deg_to_rad(2.5)
	camera.rotation.z = lerpf(camera.rotation.z, target_roll, 7.0 * delta)

func _update_hud() -> void:
	var label := get_tree().current_scene.get_node_or_null("CanvasLayer/SpeedLabel")
	if label:
		label.text = "NOVA // MOVEMENT LAB\nSPEED %03d   DASH %s\nWASD move  SPACE jump  SHIFT dash  C/CTRL slide  R restart" % [roundi(current_speed), "READY" if dash_timer <= 0.0 else "CHARGING"]

func _restart() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	head.rotation = Vector3.ZERO
