extends "res://scripts/door_down.gd"


func _on_button_panel_1_pressed() -> void:
	print("received")
	await get_tree().create_timer(.1)
	open = !open
