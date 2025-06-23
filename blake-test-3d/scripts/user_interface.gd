extends Control

#signal load_level
signal pause
signal unpause

@onready var main_menu = $Menu/MainMenu
@onready var settings_menu = $Menu/SettingsMenu
@onready var pause_menu = $Menu/PauseMenu
@onready var level_select = $Menu/LevelSelect
@onready var button_sound = $ButtonSound
@onready var controls_menu = $Menu/ControlsMenu
var loaded_level

func load_config():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err != OK:
		print("config file load error")
		return
	
	$Menu/SettingsMenu/resolution_menu.select(config.get_value("Settings", "resolution"))
	_on_resolution_menu_item_selected(config.get_value("Settings", "resolution"))
	$Menu/SettingsMenu/VolumeSlider.value = config.get_value("Settings", "volume")
	$Menu/SettingsMenu/SensitivitySlider.value = config.get_value("Settings", "mouse_sens")
	$Menu/SettingsMenu/alt_sounds_toggle.button_pressed = config.get_value("Settings", "alt_sounds")

func _ready():
	print(get_tree().current_scene.name)
	if get_tree().current_scene.name == "menu_background":
		print("config file load error")
		main_menu.show()
		settings_menu.hide()
		pause_menu.hide()
		level_select.hide()
		controls_menu.hide()
	#loaded_level = preload("res://scenes/menu_background.tscn").instantiate()
	#load_level.emit(loaded_level)
	#load_level.emit("res://scenes/menu_background.tscn")
	AltSounds.alt_sounds_on = false
	get_window().size = Vector2(1920, 1080)
	get_window().set_content_scale_size(Vector2(1920, 1080))
	load_config()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	await get_tree().create_timer(.1).timeout
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

func _unhandled_input(event):
	if !main_menu.is_visible() && !settings_menu.is_visible() && !level_select.is_visible() && !pause_menu.is_visible() && Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.show()
		get_tree().paused = true
		print("pause shown")
	elif pause_menu.is_visible() && Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_menu.hide()
		get_tree().paused = false
		print("pause hidden")

func load_level(level):
	get_tree().change_scene_to_file(level)

#main menu
func _on_level_select_button_pressed() -> void:
	button_sound.play()
	main_menu.hide()
	level_select.show()

func _on_settings_button_pressed() -> void:
	main_menu.hide()
	settings_menu.show()
	$Menu/SettingsMenu/settings_pause_back_button.hide()
	$Menu/SettingsMenu/settings_back_button.show()
	button_sound.play()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	button_sound.play()

#settings menu
func _on_settings_back_button_pressed() -> void:
	settings_menu.hide()
	main_menu.show()
	button_sound.play()
	load_config()

func _on_alt_sounds_toggle_toggled(toggled_on: bool) -> void:
	AltSounds.alt_sounds_on = toggled_on
	button_sound.play()

func _on_resolution_menu_item_selected(index: int) -> void:
	if index == 1:
		get_window().size = Vector2(2560, 1440)
		get_window().set_content_scale_size(Vector2(2560, 1440))
	elif index == 2:
		get_window().size = Vector2(1920, 1080)
		get_window().set_content_scale_size(Vector2(1920, 1080))
	elif index == 3:
		get_window().size = Vector2(1280, 720)
		get_window().set_content_scale_size(Vector2(1280, 720))
	elif index == 4:
		get_window().size = Vector2(3440, 1440)
		get_window().set_content_scale_size(Vector2(3440, 1440))

#level select

func _on_level_one_button_pressed() -> void:
	level_select.hide()
	load_level("res://scenes/level_one.tscn")

func _on_test_plane_button_pressed() -> void:
	level_select.hide()
	load_level("res://scenes/test_plane.tscn")

func _on_blake_test_3d_button_pressed() -> void:
	level_select.hide()
	load_level("res://scenes/blake_test_3d.tscn")
	#loaded_level = preload("res://scenes/blake_test_3d.tscn").instantiate()
	#load_level.emit(loaded_level)

func _on_base_level_button_pressed() -> void:
	level_select.hide()
	load_level("res://scenes/base_level.tscn")

func _on_level_select_back_button_pressed() -> void:
	level_select.hide()
	main_menu.show()
	button_sound.play()

#pause menu
func _on_pause_settings_button_pressed() -> void:
	settings_menu.show()
	pause_menu.hide()
	$Menu/SettingsMenu/settings_back_button.hide()
	$Menu/SettingsMenu/settings_pause_back_button.show()
	button_sound.play()

func _on_settings_pause_back_button_pressed() -> void:
	settings_menu.hide()
	pause_menu.show()
	button_sound.play()

func _on_back_to_game_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.hide()
	print("pause hidden")
	button_sound.play()
	get_tree().paused = false

func _on_pause_quit_button_pressed() -> void:
	pause_menu.hide()
	main_menu.show()
	button_sound.play()
	get_tree().paused = false
	load_level("res://scenes/menu_background.tscn")
	#load_level.emit(loaded_level)

func _on_controls_button_pressed() -> void:
	main_menu.hide()
	controls_menu.show()
	button_sound.play()

func _on_controls_back_button_pressed() -> void:
	controls_menu.hide()
	main_menu.show()
	button_sound.play()

#settings save choices
func _on_settings_save_button_pressed() -> void:
	var config = ConfigFile.new()
	
	config.set_value("Settings", "resolution", $Menu/SettingsMenu/resolution_menu.get_selected_id())
	config.set_value("Settings", "volume", $Menu/SettingsMenu/VolumeSlider.get_value())
	config.set_value("Settings", "mouse_sens", $Menu/SettingsMenu/SensitivitySlider.get_value())
	config.set_value("Settings", "alt_sounds", AltSounds.alt_sounds_check())
	
	config.save("user://config.cfg")

#loads level progress
func load_level_progress(current_level):
	var progress = ConfigFile.new()
	var err = progress.load("user://progress.cfg")
	if err != OK:
		print("config file load error")
		return
	print(current_level)
	print(progress.get_value("Level Checkpoint", current_level))
	return progress.get_value("Level Checkpoint", current_level)

#saves level progress
func save_level_progress(current_level, current_checkpoint):
	var progress = ConfigFile.new()
	if current_checkpoint != null:
		progress.set_value("Level Checkpoint", current_level, current_checkpoint)
	progress.save("user://progress.cfg")

#clear level progress
func clear_level_progress():
	var progress = ConfigFile.new()
	
	var err = progress.load("user://progress.cfg")
	if err != OK:
		print("config file load error")
		return
	
	progress.erase_section("Level Checkpoint")
	progress.save("user://progress.cfg")
