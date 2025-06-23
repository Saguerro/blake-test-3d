extends Node3D

signal restart

@onready var player = $player

@export var level_name : String

func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("restart"):
		#var self_node = self
		#restart.emit(self_node)
		get_tree().reload_current_scene()

func _on_player_catcher_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		$player.global_position = $world_origin.global_position

#pausing
func pause():
	process_mode = self.PROCESS_MODE_DISABLED

func unpause():
	process_mode = self.PROCESS_MODE_INHERIT
