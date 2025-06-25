extends Node3D

@onready var default_position = $platform.position
@onready var platform = $platform
@export var travel_height : float
@export var travel_speed : float

var player_on = false

func _process(delta):
	if player_on && !(platform.position.y >= default_position.y + travel_height):
		platform.position.y += delta * travel_speed
		print("platform")
	elif platform.position.y > default_position.y && !player_on:
		platform.position.y -= delta * travel_speed

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		print(player_on)
		player_on = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("character"):
		player_on = false
