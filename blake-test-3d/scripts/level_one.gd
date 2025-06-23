extends "res://scripts/base_level.gd"

@onready var message = $player_message
@onready var user_interface = $user_interface

func _ready():
	if user_interface.load_level_progress(level_name) == null:
		user_interface.save_level_progress(level_name, 0)
		message.show()
		message.text = "Move Using WASD"
		await get_tree().create_timer(3).timeout
		message.hide()
	elif user_interface.load_level_progress(level_name) == 1:
		player.global_position = $rooms/start_room/tunnel_area/triggers/checkpoint_1/checkpoint_1_spawnpoint.global_position
		message.show()
		message.text = "Press SPACE To Jump"
		await get_tree().create_timer(3).timeout
		message.hide()


func _on_door_open_trigger_body_entered(body: Node3D) -> void:
	message.hide()


func _on_checkpoint_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		if user_interface.load_level_progress(level_name) < 1:
			user_interface.save_level_progress(level_name, 1)
			message.show()
			message.text = "Press SPACE To Jump"
			await get_tree().create_timer(3).timeout
			message.hide()


func _on_player_jump_fail_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		self.restart


func _on_jump_success_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		message.hide()
