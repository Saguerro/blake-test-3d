extends "res://scripts/door_down.gd"


func _on_door_open_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		open = true
		await get_tree().create_timer(.25).timeout
		animated.set_collision_layer_value(1, false)


func _on_door_close_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		open = false
		animated.set_collision_layer_value(1, true)
