extends "res://scripts/base_level.gd"

@onready var gun_picked_up = false
@onready var user_interface = $UserInterface

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

func _ready() -> void:
	if user_interface.load_level_progress(level_name) == null:
		user_interface.save_level_progress(level_name, 0)
	elif user_interface.load_level_progress(level_name) == 1:
		player.global_position = $checkpoint1/checkpoint_1.global_position
	elif user_interface.load_level_progress(level_name) == 2:
		player.global_position = $checkpoint2/checkpoint_2.global_position

func _physics_process(delta):
	get_tree().call_group("enemy", "update_player_location", player.global_transform.origin)


func _on_gun_pickup_player_entered() -> void:
	gun_picked_up = true
	$player/weapon_manager.current_weapon = preload("res://weapon_manager/crowbar/deagle.tres").duplicate()
	$player/weapon_manager.update_weapon_model()


func _on_checkpoint_1_body_entered(body: Node3D) -> void:
	if user_interface.load_level_progress(level_name) <= 1:
		user_interface.save_level_progress(level_name, 1)


func _on_checkpoint_2_body_entered(body: Node3D) -> void:
	if user_interface.load_level_progress(level_name) <= 2:
		user_interface.save_level_progress(level_name, 2)	
