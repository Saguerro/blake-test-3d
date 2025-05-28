extends AnimatableBody3D

var toggled = false


func _process(delta):
	if toggled:
		position.y = lerp(position.y, -3.0, delta * 10.0)
	else:
		position.y = lerp(position.y, 1.0, delta * 10.0)

func _on_button_toggle() -> void:
	print("received")
	await get_tree().create_timer(.1)
	toggled = !toggled
