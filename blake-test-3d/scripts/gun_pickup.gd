extends Node3D

signal player_entered


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("character"):
		player_entered.emit()
		self.queue_free()

func _process(delta):
	rotation.y = rotation.y - delta
