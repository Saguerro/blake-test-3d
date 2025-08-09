extends Node3D

@onready var iris = $iris.mesh.surface_get_material(1)
@onready var animation_player = $AnimationPlayer

signal seen_finished
signal lost_finished
signal attack_finished

func player_seen():
	animation_player.play("player_seen")


func player_lost():
	animation_player.play("player_lost")


func show_idle():
	pass


func show_angry_idle():
	pass


func attack():
	animation_player.play("attack")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "player_seen":
		seen_finished.emit()
	elif anim_name == "player_lost":
		lost_finished.emit()
	elif anim_name == "attack":
		attack_finished.emit()
	else:
		print("error playing mech_eye animation")
