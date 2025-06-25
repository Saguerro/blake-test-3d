extends Node3D

@onready var animated = $door_animated
@onready var default_position = animated.position.y

var open = false


func _process(delta):
	if open:
		animated.position.y = lerp(animated.position.y, default_position - 2.24, delta * 10.0)
	else:
		animated.position.y = lerp(animated.position.y, default_position, delta * 10.0)

func close_door():
		open = false
		animated.set_collision_layer_value(1, true)

func open_door():
		open = true
		await get_tree().create_timer(.25).timeout
		animated.set_collision_layer_value(1, false)
