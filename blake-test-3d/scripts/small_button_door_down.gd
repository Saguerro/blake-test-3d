extends "res://scripts/door_down.gd"

func _on_door_animated_door_pressed():
	print("input read")
	open = true
	await get_tree().create_timer(3).timeout
	open = false
