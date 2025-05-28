extends StaticBody3D

signal toggle

@onready var default_z = position.z

var is_pressed = false


func _process(delta):
	if is_pressed:
		position.z = lerp(position.z, default_z - .10, delta * 5)
	else:
		position.z = lerp(position.z, default_z, delta * 5)

func pressed():
	is_pressed = !is_pressed
	toggle.emit()
	$pressed_timer.start()
	print("pressed")


func _on_pressed_timer_timeout() -> void:
	is_pressed = false
