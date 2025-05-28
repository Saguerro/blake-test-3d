extends Node3D

@onready var animated = $door_animated
@onready var default_position = animated.position.y
var open = false


func _process(delta):
	if open:
		animated.position.y = lerp(animated.position.y, default_position - 2.25, delta * 10.0)
	else:
		animated.position.y = lerp(animated.position.y, default_position, delta * 10.0)
