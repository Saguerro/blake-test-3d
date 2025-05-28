extends HSlider


@export var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = .5
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	$volume_slider_label.text = "Volume: " + str(value)


func _on_value_changed(set_value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(set_value))
	$volume_slider_label.text = "Volume: " + str(set_value)
