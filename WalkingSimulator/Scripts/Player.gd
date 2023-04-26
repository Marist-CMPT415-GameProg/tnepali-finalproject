extends KinematicBody

export var walk_speed: float = 1
export var run_speed: float = 4
export var jump_strength: float = 5
export var move_speed: float = 5
export var gravity: float = 12
var velocity: Vector3 = Vector3()
var is_visible = true

#Camera Look
var MAX_LOOK_ANGLE: float = 90
var MIN_LOOK_ANGLE: float = -90
var sensitivity: float = 10
var mouse_delta: Vector2 = Vector2()
onready var camera: Camera = get_node("Camera")
onready var timer_invisibility: Timer = $TimerOfInvisibility
onready var invisibility_bar: ProgressBar = $ViewportContainer/GUI/InvisibilityBar
onready var gui = $ViewportContainer/GUI


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gui.visible = true


func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative


func _process(delta):
	camera.rotation_degrees.y -= mouse_delta.y * sensitivity * delta
	camera.rotation_degrees.y = clamp(camera.rotation_degrees.x, MIN_LOOK_ANGLE, MAX_LOOK_ANGLE)
	rotation_degrees.y -= mouse_delta.x * sensitivity * delta
	mouse_delta = Vector2()
	invisibility_bar_handler()


# Called 60 time per second
func _physics_process(delta):
	var input_dir: Vector3 = Vector3()
	if Input.is_action_just_pressed("move_forward"):
		#Idea 1: use a timer to decide whether the next forward key triggers run
		#Idea 2: accumulate deltas to determine the elapsed time since last forward press
		pass

	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	var forward: Vector3 = global_transform.basis.z
	var right: Vector3 = global_transform.basis.x

	var relative_dir = forward * input_dir.z + right * input_dir.x

	var move_speed = run_speed if Input.is_action_pressed("run") else walk_speed
	velocity.x = relative_dir.x * move_speed
	velocity.z = relative_dir.z * move_speed
	velocity.y -= gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_strength

	velocity = move_and_slide(velocity, Vector3.UP)

	for index in range(get_slide_count()):
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("tripping_hazard"):
			#TODO decide what tripping the player means
			var knockback_force = 20
			var knockback_dir = -forward
			velocity += knockback_dir
			pass


func invisibility_bar_handler():
	if is_visible:
		return
	invisibility_bar.value = timer_invisibility.time_left / timer_invisibility.wait_time


func on_invisibility_potion_end():
	is_visible = true
	invisibility_bar.visible = false


func on_interact_area_enter(area: Area):
	if area.is_in_group("consumable"):
		area.consume(self)
