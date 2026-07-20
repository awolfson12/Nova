extends CharacterBody3D

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
@export var rail_jump_vertical := 7.5
@export var rail_attach_lockout := 0.35

var head: Node3D
var camera: Camera3D
var dash_timer := 0.0
var portal_cooldown := 0.0
var rail_lockout := 0.0
var spawn_position := Vector3.ZERO
var is_sliding := false
var current_speed := 0.0
var active_rail: NovaGrindRail
var rail_offset := 0.0
var rail_direction := 1.0
var grind_speed := 0.0

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
	portal_cooldown = maxf(0.0, portal_cooldown - delta)
	rail_lockout = maxf(0.0, rail_lockout - delta)
	if Input.is_action_just_pressed("restart") or global_position.y < -12.0:
		_restart()

	if active_rail != null:
		_process_grinding(delta)
	else:
		_process_free_movement(delta)
		_try_attach_to_rail()

	_update_camera(delta)
	_update_hud()

func _process_free_movement(delta: float) -> void:
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
		var dash_direction := wish_direction if wish_direction != Vector3.ZERO else -transform.basis.z
		velocity += dash_direction.normalized() * dash_impulse
		dash_timer = dash_cooldown
	move_and_slide()

func _process_grinding(delta: float) -> void:
	if not is_instance_valid(active_rail):
		_release_rail(false)
		return
	var tangent := active_rail.tangent_at(rail_offset) * rail_direction
	var throttle := Input.get_axis("move_back", "move_forward")
	grind_speed = clamp(grind_speed + active_rail.boost_acceleration * (0.35 + maxf(throttle, 0.0)) * delta, sprint_speed, active_rail.max_grind_speed)
	rail_offset += grind_speed * rail_direction * delta
	if rail_offset <= 0.0 or rail_offset >= active_rail.rail_length:
		_release_rail(false)
		return
	global_position = active_rail.point_at(rail_offset) + Vector3.UP * 0.72
	velocity = tangent * grind_speed
	var target_yaw := atan2(-tangent.x, -tangent.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, minf(1.0, 10.0 * delta))
	if Input.is_action_just_pressed("jump"):
		_release_rail(true)
	elif Input.is_action_just_pressed("dash") and dash_timer <= 0.0:
		grind_speed = minf(active_rail.max_grind_speed, grind_speed + dash_impulse)
		dash_timer = dash_cooldown

func _try_attach_to_rail() -> void:
	if rail_lockout > 0.0 or velocity.length() < 7.0:
		return
	var best_rail: NovaGrindRail
	var best_distance := INF
	for node in get_tree().get_nodes_in_group("grind_rails"):
		if node is NovaGrindRail and node.is_near(global_position):
			var offset := node.nearest_offset(global_position)
			var distance := node.point_at(offset).distance_to(global_position)
			if distance < best_distance:
				best_distance = distance
				best_rail = node
	if best_rail == null:
		return
	active_rail = best_rail
	rail_offset = active_rail.nearest_offset(global_position)
	var tangent := active_rail.tangent_at(rail_offset)
	rail_direction = 1.0 if velocity.dot(tangent) >= 0.0 else -1.0
	grind_speed = maxf(sprint_speed, velocity.length())
	is_sliding = false

func _release_rail(jumped: bool) -> void:
	if active_rail == null:
		return
	var tangent := active_rail.tangent_at(rail_offset) * rail_direction
	velocity = tangent * grind_speed
	if jumped:
		velocity.y += rail_jump_vertical
	active_rail = null
	rail_lockout = rail_attach_lockout

func _apply_ground_movement(wish_direction: Vector3, delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if wish_direction == Vector3.ZERO:
		horizontal = horizontal.move_toward(Vector3.ZERO, ground_friction * delta)
	else:
		var target_speed := maxf(horizontal.length(), sprint_speed * 1.15) if is_sliding else sprint_speed
		horizontal = horizontal.move_toward(wish_direction * target_speed, ground_acceleration * (0.35 if is_sliding else 1.0) * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if is_sliding:
		velocity += -transform.basis.z * 5.0 * delta

func _apply_air_movement(wish_direction: Vector3, delta: float) -> void:
	if wish_direction == Vector3.ZERO:
		return
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	horizontal = horizontal.move_toward(wish_direction * sprint_speed, air_acceleration * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

func _apply_vertical_physics(delta: float) -> void:
	var wall_running := is_on_wall() and velocity.y <= 2.0 and Vector2(velocity.x, velocity.z).length() > 8.0
	if wall_running:
		velocity.y -= wall_run_gravity * delta
		if Input.is_action_just_pressed("jump"):
			velocity += get_wall_normal() * wall_jump_push
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta

func _update_camera(delta: float) -> void:
	current_speed = grind_speed if active_rail != null else Vector2(velocity.x, velocity.z).length()
	var speed_ratio := clamp(current_speed / 42.0, 0.0, 1.0)
	camera.fov = lerpf(camera.fov, 80.0 + speed_ratio * 24.0, 7.5 * delta)
	head.position.y = lerpf(head.position.y, 0.25 if is_sliding else 0.72, 12.0 * delta)
	var target_roll := (-Input.get_axis("move_left", "move_right") * deg_to_rad(2.5))
	if active_rail != null:
		target_roll += deg_to_rad(7.0) * rail_direction
	camera.rotation.z = lerpf(camera.rotation.z, target_roll, 7.0 * delta)

func _update_hud() -> void:
	var label := get_tree().current_scene.get_node_or_null("CanvasLayer/SpeedLabel")
	if label:
		var state := "GRINDING" if active_rail != null else "FREE"
		label.text = "NOVA // RAIL LAB\nSPEED %03d   %s   DASH %s\nLMB blue  RMB orange | SPACE jump-off | SHIFT boost" % [roundi(current_speed), state, "READY" if dash_timer <= 0.0 else "CHARGING"]

func can_use_portal() -> bool:
	return portal_cooldown <= 0.0

func mark_portal_used() -> void:
	portal_cooldown = 0.22
	if active_rail != null:
		_release_rail(false)

func _restart() -> void:
	active_rail = null
	global_position = spawn_position
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	head.rotation = Vector3.ZERO
	portal_cooldown = 0.0
	rail_lockout = 0.0
