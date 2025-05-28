extends AnimatableBody3D

signal door_pressed

func pressed():
	print("input sent")
	door_pressed.emit()
