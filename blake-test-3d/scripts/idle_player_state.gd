class_name idle_player_state

extends State


func update(delta):
	if Global.player.velocity.length() > 0.0 && Global.player.is_on_floor():
		transition.emit("WalkingPlayerState")
