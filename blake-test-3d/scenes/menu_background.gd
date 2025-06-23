extends Node3D

@onready var user_interface = $user_interface

func _ready():
	user_interface.clear_level_progress()
