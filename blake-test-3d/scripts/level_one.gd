extends "res://scripts/base_level.gd"

@onready var message = $player_message
@onready var user_interface = $user_interface

func _ready():
	match(user_interface.load_level_progress(level_name)):
		null: 
			user_interface.save_level_progress(level_name, 0)
			tutorial_message("Move Using WASD")
		1:
			player.global_position = $rooms/start_room/tunnel_area/triggers/checkpoint_1/checkpoint_1_spawnpoint.global_position
			tutorial_message("Press SPACE To Jump")


func tutorial_message(text):
	message.show()
	message.text = text
	await get_tree().create_timer(3).timeout
	message.hide()


func _on_door_open_trigger_body_entered(body: Node3D) -> void:
	message.hide()


func _on_checkpoint_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		if user_interface.load_level_progress(level_name) < 1:
			user_interface.save_level_progress(level_name, 1)
			tutorial_message("Press SPACE To Jump")


func _on_player_jump_fail_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		get_tree().reload_current_scene()


func _on_jump_success_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		message.hide()


func _on_crouch_tutorial_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		tutorial_message("Press C to Crouch")


func _on_shift_tutorial_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		tutorial_message("Press SHIFT to Sprint")
