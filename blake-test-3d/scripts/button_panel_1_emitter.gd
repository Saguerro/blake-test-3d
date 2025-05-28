extends Node3D

signal pressed

func _on_button_animated_toggle() -> void:
	pressed.emit()
