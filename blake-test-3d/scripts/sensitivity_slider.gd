extends HSlider


@export var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = 1
	$sensitivity_slider_label.text = "Mouse Sensitivity: " + str(value)


func _on_value_changed(set_value: float) -> void:
	MouseSensitivity.mouse_sens = MouseSensitivity.BASE_MOUSE_SENS * set_value
	$sensitivity_slider_label.text = "Mouse Sensitivity: " + str(value)
