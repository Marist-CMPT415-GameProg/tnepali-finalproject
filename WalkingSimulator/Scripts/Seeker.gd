extends KinematicBody

var path = []
var path_node = 0

export var speed = 5

export var sight_range = 25
export var angle_of_sight_degrees = 75

onready var nav: Navigation = get_tree().get_nodes_in_group("navigation")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]
var previus_player_position: Vector3 = Vector3.ZERO

var velocity: Vector3 = Vector3.ZERO
var direction_to_look_at: Vector3 = Vector3.ZERO

var is_last_known_position_checked = false

export var map_radius = 100

var seeker_prefab = load("res://Scenes/SeekerPrefab.tscn")

onready var wander_wait_timer: Timer = $WanderWaitTime


func _process(delta):
	if is_player_in_sight():
		chase(delta)
	else:
		wander(delta)
	if is_last_known_position_checked == true and is_player_in_sight():
		is_last_known_position_checked = false


func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector3.UP)

	var angle = atan2(direction_to_look_at.x, direction_to_look_at.z)
	rotation.y = lerp_angle(rotation.y, angle, 5 * delta)


func chase(_delta):
	if path_node < path.size():
		var direction = path[path_node] - global_transform.origin
		if direction.length_squared() < 10:
			path_node += 1

		velocity = direction.normalized() * speed
	else:
		is_last_known_position_checked = true

	direction_to_look_at = player.global_transform.origin - global_transform.origin


func wander(delta):
	# Check last position of player was in sight.
	if is_last_known_position_checked == false:
		if path_node < path.size():
			var direction = path[path_node] - global_transform.origin
			if direction.length_squared() < 10:
				path_node += 1

			velocity = direction.normalized() * speed
		else:
			is_last_known_position_checked = true
	# Wander randomly
	else:
		if path_node < path.size():
			var direction = path[path_node] - global_transform.origin
			if direction.length_squared() < 10:
				path_node += 1

			velocity = direction.normalized() * speed
		else:
			if wander_wait_timer.is_stopped() == true:
				wander_wait_timer.start()
	direction_to_look_at = velocity * delta


func move_to(target_pos: Vector3):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0


func on_calculate_path():
	if previus_player_position.is_equal_approx(player.global_transform.origin):
		return
	if not is_player_in_sight():
		return
	move_to(player.global_transform.origin)
	previus_player_position = player.global_transform.origin


func is_player_in_sight() -> bool:
	if player.is_visible == false:
		return false

	var my_pos = global_transform.origin + Vector3.UP * 2
	var player_pos = player.global_transform.origin + Vector3.UP * 2

	# Check if player is in angle of sight.
	var dir_to_player = my_pos.direction_to(player_pos)
	var forwards = global_transform.basis.z

	if rad2deg(forwards.angle_to(dir_to_player)) > angle_of_sight_degrees:
		return false

	# Check if player is in range of sight.
	if my_pos.distance_to(player_pos) > sight_range:
		return false

	# Check if no obstecels are in the way of sight.
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(my_pos, player_pos, [], 2)

	return !result


func multiply():
	var new_seeker = seeker_prefab.instance()
	get_tree().current_scene.add_child(new_seeker)
	new_seeker.global_transform.origin = global_transform.origin


func wander_wait_end():
	var random_point = nav.get_closest_point(
		Vector3(rand_range(-1, 1), 2, rand_range(-1, 1)) * map_radius
	)
	move_to(random_point)
	wander_wait_timer.stop()


func _on_Area_body_entered(body: Node):
	if body.is_in_group("player"):
		game_manager.game_over()
