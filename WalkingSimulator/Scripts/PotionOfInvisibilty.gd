extends Area

export var direction: float = 5

onready var animation = $AnimationPlayer


func consume(player):
	player.is_visible = false
	player.timer_invisibility.start(direction)
	player.invisibility_bar.visible = true
	animation.play("Consume")
