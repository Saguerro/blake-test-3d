extends "res://scripts/base_level.gd"

@onready var gun_picked_up = false

func _input(event):
	super(event)
	if Input.is_action_just_pressed("equip") && gun_picked_up:
		if $player/weapon_manager.current_weapon == null:
			$player/weapon_manager.current_weapon = preload("res://weapon_manager/crowbar/deagle.tres").duplicate()
			$player/weapon_manager.update_weapon_model()
		else:
			print($player/weapon_manager.current_weapon)
			$player/weapon_manager.current_weapon = null
			$player/weapon_manager.update_weapon_model()


func _physics_process(delta):
	get_tree().call_group("enemy", "update_player_location", player.global_transform.origin)


func _on_gun_pickup_player_entered() -> void:
	gun_picked_up = true
	$player/weapon_manager.current_weapon = preload("res://weapon_manager/crowbar/deagle.tres").duplicate()
	$player/weapon_manager.update_weapon_model()
