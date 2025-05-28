extends Node3D

@onready var top_r_piece = $door_pieces/door_top_right
@onready var top_l_piece = $door_pieces/door_top_left
@onready var bot_r_piece = $door_pieces/door_bottom_right
@onready var bot_l_piece = $door_pieces/door_bottom_left
@onready var hit_direction = $hit_direction

func _on_player_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		var player_facing = body.get_global_transform().basis.z
		if body.sliding == true && (player_facing.dot($player_detector/detector_collision.get_global_transform().basis.z) > .9):
			print("touched")
			top_r_piece.freeze = false
			top_l_piece.freeze = false
			bot_r_piece.freeze = false
			bot_l_piece.freeze = false
			
			top_r_piece.set_collision_layer_value(8, false)
			top_l_piece.set_collision_layer_value(8, false)
			bot_r_piece.set_collision_layer_value(8, false)
			bot_l_piece.set_collision_layer_value(8, false)
			
			top_r_piece.apply_impulse(body.velocity * 2 * (top_r_piece.global_position - hit_direction.global_position))
			top_l_piece.apply_impulse(body.velocity * 2 * (top_l_piece.global_position - hit_direction.global_position))
			bot_r_piece.apply_impulse(body.velocity * 2 * (bot_r_piece.global_position - hit_direction.global_position))
			bot_l_piece.apply_impulse(body.velocity * 2 * (bot_l_piece.global_position - hit_direction.global_position))
			
			await get_tree().create_timer(.25).timeout
			
			top_r_piece.add_to_group("grabbable")
			top_l_piece.add_to_group("grabbable")
			bot_l_piece.add_to_group("grabbable")
			bot_r_piece.add_to_group("grabbable")
			
			top_r_piece.set_collision_layer_value(8, true)
			top_l_piece.set_collision_layer_value(8, true)
			bot_r_piece.set_collision_layer_value(8, true)
			bot_l_piece.set_collision_layer_value(8, true)
