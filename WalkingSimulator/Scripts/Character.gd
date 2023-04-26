extends KinematicBody
signal do_look(look)
signal do_turn(angle)
export var WALK_SPEED = 2.0 
export var RUN_SPEED =  5.0 
export var JUMP_HEIGHT = 2.0 
export var GRAVITY = -9.81 
var direction:Vector3 = Vector3.ZERO 

export var third_person_pos = Vector3(0,1.5,5)
export var lookaround_speed = 0.05 
export var top_clamp = 90 
export var bottom_clamp = 0 

var target: Spatial 
var camera_rotation:Vector2 

#var camera_pitch:float 
#var camera_yaw:float 

var velocity:Vector3 = Vector3.ZERO 
var normal_scale:Vector3 = Vector3(1,1,1)
var crouch_scale:Vector3 = Vector3(1,0.5,1)
func _ready():
	target = get_node(follow_target)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	top_clamp = deg2rad(top_clamp)
	bottom_clamp = deg2rad(bottom_clamp)
	

func zoom(zoom_in:bool): 
	var camera = get_viewport().get_camera()
	if zoom_in: 
		$Tween.interpolate_property(camera,"position", camera.position, Vector3.ZERO,0.2)
	else: 
		$Tween.interpolate_property(camera,"position", camera.position, third_person_pos,0.2)


func _input(event): 
	if event is InputEventMouseMotion: 
		var view_delta = -event.relative * lookaround_speed 
		camera_rotation += view_delta 
		camera_rotation.y = min(camera_rotation.y, top_clamp)
		camera_rotation.y = min(camera_rotation.y, bottom_clamp)
		look(camera_rotation)
		#if is_first_person(): 
		emit_signal(("do turn", global_rotation.y))
		
		
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_WHEEL_UP: 
			zoom(true)
		elif event.button_index == BUTTON_WHEEL_DOWN: 
			zoom(false)
	var input_dir:Vector2 = Input.get_vector("move_left","move_right","move_backward","move_forward")
	var direction:Vector3 = (transform.basis * Vector3(input_dir.x,0,input_dir.y))
	direction = direction.normalized() *WALK_SPEED
	
	
	
	
	if event.is_action_pressed("crouch") and not event.is_echo():
		crouch(event.is_pressed())
		
func look(camera_rotation:Vector2):
	transform.basis = Basis.IDENTITY 
	rotate_object_local(Vector3.UP, camera_rotation.x) #(0,1,0)
	rotate_object_local(Vector3.RIGHT, camera_rotation.y)
	look(camera_rotation)
	
func _physics_process(delta): 
	if not is_on_floor(): 
		velocity.y += GRAVITY * delta 
	elif Input.is_action_pressed("jump"): 
		velocity.y += JUMP_HEIGHT * -GRAVITY 
		
	
	velocity.x = direction.x 
	velocity.z = direction.z
	velocity = move_and_slide(velocity,Vector3.UP)
	
	
func crouch(is_crouching:bool):
	if do_crouch:
		$Tween.interpolate_property(self,scale,Vector3(1,1,1), Vector3(1,0.5,1),0.1)
		#scale = Vector3(0,0.5,0)
	else: 
		$Tween.interpolate_property(self,scale,Vector3(1,0.5,1), Vector3(1,1,1),0.1)
func on_move(input_dir:Vector2): 
	direction = transform.basis * Vector3(input_dir)
