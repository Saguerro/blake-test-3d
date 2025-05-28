extends Node3D

@onready var default_position = $platform.position
@onready var player_detector = $platform/Area3D
@onready var platform = $platform
@export var travel_distance : float
@export var travel_speed : float

var player_on = false
var moving = false
var left_from_default = false
var left_from_new = false


func _process(delta):
	if player_on && !moving:
		moving = true
		player_on = false
		print("platform")
		if platform.position.x <= default_position.x:
			left_from_default = true
		elif platform.position.x >= default_position.x + travel_distance:
			left_from_new = true
	elif moving:
		player_on = false
	if moving:
		if left_from_default:
			if ((default_position.x + travel_distance) - platform.position.x) < travel_speed * delta:
				platform.position.x = default_position.x + travel_distance
			else:
				platform.position.x += travel_speed * delta
		elif left_from_new:
			if platform.position.x - default_position.x < travel_speed * delta:
				platform.position.x = default_position.x
			else:
				platform.position.x -= travel_speed * delta

	if platform.position.x == default_position.x + travel_distance && left_from_default:
		moving = false
		left_from_default = false
	elif platform.position.x == default_position.x && left_from_new:
		moving = false
		left_from_new = false


func _physics_process(delta):
	for body in player_detector.get_overlapping_bodies():
		if body.is_in_group("character") && left_from_default:
			print("applied_velo")
			body.position.x -= travel_speed * delta
		elif body.is_in_group("character") && left_from_new:
			body.position.x += travel_speed * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		print(player_on)
		player_on = true
