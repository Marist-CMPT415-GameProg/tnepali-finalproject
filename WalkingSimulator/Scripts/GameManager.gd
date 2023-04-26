extends Node

var gui
var game_over_screen
var game_over_retray_button

var player

var scene = load("res://Scenes/Outdoors.tscn")


func _ready():
	call_deferred("load")


func load():
	player = get_tree().get_nodes_in_group("player")[0]
	gui = $ViewportContainer/GUI
	game_over_screen = $ViewportContainer/GUI/GameOverScreen
	game_over_retray_button = $ViewportContainer/GUI/GameOverScreen/Retray
	gui.visible = false
	game_over_screen.visible = false


func game_over():
	gui.visible = true
	game_over_screen.visible = true
	player.gui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func on_retray_pressed():
	assert(get_tree().change_scene_to(scene) == 0)
	call_deferred("load")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
