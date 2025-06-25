extends CharacterBody3D

@onready var nav_agent = $enemy_nav_agent
@onready var vision_timer = $vision_cone/vision_timer
@onready var vision_raycast = $vision_cone/vision_raycast
@onready var aggro_timer = $vision_cone/aggro_timer
@onready var current_hp = max_hp
@onready var attack_node = $attack
@onready var attack_timer = $Timers/attack_timer
@onready var attack_default_pos = attack_node.position
@onready var attack_hitbox = $attack/attack_hitbox
@onready var attack_cooldown = $Timers/attack_cooldown_timer
@onready var enemy_mesh_material = $enemy_mesh.mesh.material

@export var max_hp = 200.0

enum EnemyState {IDLE, CHASE, ATTACk, HURT}

var can_attack = true
var current_state := EnemyState.IDLE
var SPEED = 3.0
var player_location

func _ready():
	pass

#runs code based on current state
func _process(delta):
	match(current_state):
		EnemyState.IDLE: _idle_state()
		EnemyState.CHASE: _chase_state(delta)
		EnemyState.ATTACk: _attack_state(delta)
	
	
	nav_agent.target_position = player_location

#temporary chase starter
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_button"):
		print("read")
		if current_state == EnemyState.IDLE:
			current_state = EnemyState.CHASE
		elif current_state == EnemyState.CHASE:
			current_state = EnemyState.IDLE
			


func _idle_state():
	pass
	#if nav_agent.target_location != null:
	#	current_state = EnemyState.CHASE
	#	return

#controls chase behavior
func _chase_state(delta):
	var pos2d := Vector2(global_position.x, global_position.z)
	var player_pos2d := Vector2(player_location.x, player_location.z)
	var direction = pos2d - player_pos2d
	rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.y), delta * 10)
	#if nav_agent.target_location == null:
	#	current_state = EnemyState.IDLE
	#	return

#controls attack behavior
func _attack_state(delta):
	attack_node.position.z = move_toward(attack_node.position.z, attack_default_pos.z - 2, delta * 10)
	attack_node.scale.z = move_toward(attack_node.scale.z, 5.0, delta * 15)
	#print("attacking")
	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("character"):
			body.take_damage(25)

func _hurt_state():
	pass

#controls movement and attack start
func _physics_process(delta: float) -> void:
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	if current_state == EnemyState.CHASE:
		#look_at(Vector3(player_location.x, 1, player_location.z))
		#var diff = Vector2(player_location.x - global_position.x, player_location.y - global_position.y)
		#rotation.y += atan2(deg_to_rad(diff.y), deg_to_rad(diff.x))
		#look_at(player_location)
		if !nav_agent.is_target_reached():	
			velocity = new_velocity
			move_and_slide()
		elif can_attack:
			print(can_attack)
			can_attack = false
			print("attack_started")
			enemy_mesh_material.albedo_color = Color(1,0,0)
			await get_tree().create_timer(.05).timeout
			enemy_mesh_material.albedo_color = Color(.5,0,0)
			await get_tree().create_timer(.4).timeout
			
			attack_timer.start()
			current_state = EnemyState.ATTACk

#stores player location
func update_player_location(target_location):
	player_location = target_location

#damage functions
func take_damage(amount : int): 
	current_hp -= amount
	if current_hp > 0: update_health_bar()
	if current_hp <= 0:
		self.queue_free()

#updates health bar based on current health upon call
func update_health_bar():
	var health_bar = $health_bar/SubViewport/ProgressBar
	
	health_bar.value = (current_hp / max_hp) * 100
	print(str(health_bar.value))

#checks if player is visible in current sight range
func _on_vision_timer_timeout() -> void:
	var overlaps = $vision_cone.get_overlapping_bodies()
	if overlaps.size() > 0:
		var found = false
		for overlap in overlaps:
			if overlap.name == "player":
				var player_position = Vector3(overlap.global_position.x, overlap.global_position.y + 1, overlap.global_position.z)
				vision_raycast.look_at(player_position, Vector3.UP)
				vision_raycast.force_raycast_update()
				found = true
				if vision_raycast.is_colliding():
					#print("collision detected")
					var collider = vision_raycast.get_collider()
					
					if collider.name == "player" && !current_state == EnemyState.ATTACk:
						vision_raycast.debug_shape_custom_color = Color(255, 0, 0)
						current_state = EnemyState.CHASE
						#print("balls")
					elif !current_state == EnemyState.ATTACk:
						current_state = EnemyState.CHASE
						aggro_timer.start()
						vision_raycast.debug_shape_custom_color = Color(0, 255, 0)
	vision_timer.start()

#moves to idle state from chase if player not visible after a few seconds
func _on_aggro_timer_timeout() -> void:
	if current_state == EnemyState.CHASE:
		current_state = EnemyState.IDLE

func on_hit():
	pass

#controls attack duration and end behavior
func _on_attack_timer_timeout() -> void:
	print("attack finished")
	current_state = EnemyState.CHASE
	attack_node.position.z = attack_default_pos.z
	attack_node.scale.z = 1
	attack_cooldown.start()


func _on_attack_cooldown_timer_timeout() -> void:
	print("attack_enabled")
	can_attack = true
