extends Decal

@onready var fade_out_timer = get_tree().create_timer(1.5)

func _process(delta):
	var time_left = 0.15 * ((fade_out_timer.time_left - 1) * 2)
	if fade_out_timer.time_left >= 1:
		$CubeParticle.draw_pass_1.size = Vector3(time_left, time_left, time_left)
		print(time_left)
		print(fade_out_timer.time_left)
