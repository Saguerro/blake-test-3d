extends Node3D


@onready var hud_timer = $HUD/TrialTimer/CurrentTime
@onready var hud_best_time = $HUD/TrialTimer/BestTime
@onready var deagle_instance = preload("res://weapon_manager/crowbar/deagle.tres").duplicate()

var trial_timer := 0.0
var trial_running := false
var best_time := 999.9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD/IntroText.show()
	$player/UserInterface/Reticle.hide()
	await get_tree().create_timer(3).timeout
	$HUD/IntroText.hide()
	$player/UserInterface/Reticle.show()

func _input(event: InputEvent):
	if Input.is_action_just_pressed("equip"):
		if $player/weapon_manager.current_weapon == null:
			$player/weapon_manager.current_weapon = deagle_instance
			$player/weapon_manager.update_weapon_model()
		else:
			print($player/weapon_manager.current_weapon)
			$player/weapon_manager.current_weapon = null
			$player/weapon_manager.update_weapon_model()
	
	if Input.is_action_pressed("restart"):
		$player.global_position = $world_origin.global_position
		trial_running = false
		trial_timer = 0.0
		hud_timer.text = "Time: 0.0"

#pausing
func pause():
	process_mode = self.PROCESS_MODE_DISABLED

func unpause():
	process_mode = self.PROCESS_MODE_INHERIT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trial_running:
		trial_timer += delta
		hud_timer.text = "Time: %s" % snapped(trial_timer, .01)

#trial start
func _on_trial_start_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		trial_running = true
		print("trial started")

#trial end
func _on_trial_end_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		print("trial ended")
		if trial_timer < best_time and trial_running:
			best_time = trial_timer
			hud_best_time.text = "Best time: %s" % snapped(best_time, .01)
		trial_running = false
		trial_timer = 0.0
		$player.global_position = $world_origin.global_position


func _on_player_catcher_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		$player.global_position = $world_origin.global_position
		trial_running = false
		trial_timer = 0.0
