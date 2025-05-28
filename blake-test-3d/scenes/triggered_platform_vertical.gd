extends Node3D

@onready var default_position = $platform.position
@onready var platform = $platform
@export var travel_height : float
@export var travel_speed : float

var up = false

func _process(delta):
	if up && !(platform.position.y >= default_position.y + travel_height):
		platform.position.y += delta * travel_speed
		print("platform")
	elif platform.position.y > default_position.y && !up:
		platform.position.y -= delta * travel_speed

func _on_button_panel_1_pressed() -> void:
	up = !up
	print(up)
