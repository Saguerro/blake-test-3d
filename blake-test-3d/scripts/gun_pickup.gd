extends Node3D

signal player_entered

@onready var deagle = $deagle


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		player_entered.emit()
		self.queue_free()

func _process(delta):
	deagle.rotation.y = deagle.rotation.y - delta
