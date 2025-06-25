extends "res://scripts/door_down.gd"


func _on_door_open_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		open_door()


func _on_door_close_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		close_door()
