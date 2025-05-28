extends CharacterBody3D

#player nodes
@onready var neck: Node3D = $Model/neck
@onready var head_pivot: Node3D = $Model/neck/headPivot
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $CrouchRaycast
@onready var eyes: Node3D = $Model/neck/headPivot/eyes
@onready var animation_player: AnimationPlayer = $Model/neck/headPivot/eyes/AnimationPlayer
@onready var flashlight: SpotLight3D = $Model/neck/headPivot/Flashlight

#speed vars
var target_speed = 5.0
@export var walking_speed = 7.5
@export var sprinting_speed = 15.0
@export var crouching_speed = 5.0

#states
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#slide vars
var slide_timer = 0.5
var slide_timer_max = 1.25
var slide_vector = Vector2.ZERO
var slide_speed = 15.0

#head bobbing vars
@export var headbob_frequency = 1.75
@export var headbob_amplitude = .04
var headbob_time = 0.0
var footstep_can_play = true
var footstep_landed

#move tilt vars
var tilt_intensity = 15.0

#movement vars
@export var jump_velocity = 9
var lerp_speed = 10.0
var crouch_depth = -.6 
var free_look_tilt_amount = 4.0
var air_lerp_speed = 3
var last_velocity = Vector3.ZERO
var wall_friction = .9
var wall_runnable = false
var coyote = false
var jump_buffer = false
var double_jump = false
var coyote_buffer = false

#input vars
var mouse_sens = 0.2
var direction = Vector3.ZERO
var mouse_free = false

#item vars




func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


func _input(event):
	
	#mouse looking logic
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head_pivot.rotation.x = clamp(head_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	#flashlight logic
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	
	if Input.is_action_just_pressed("mouse_free"):
		if !mouse_free:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_free = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_free = false


#wall run and jump logic
func wall_run():
	if (is_on_wall_only() and coyote) and wall_runnable and Input.is_action_pressed("sprint"):
		if !$Sounds/WallSound.playing:
			$Sounds/WallSound.play()
		target_speed = 20.0
		velocity.y *= .95
		if Input.is_action_just_pressed("jump") || jump_buffer:
			coyote_buffer = true
			$Timers/CoyoteBuffer.start()
			double_jump = true
			sprinting_speed = 20.0
			$Sounds/FootstepAudio3D.play()
			$Sounds/SlideSound.stop()
			direction = get_wall_normal() * .8
			velocity.y = jump_velocity
			jump_buffer = false
	else:
		$Sounds/WallSound.stop()

#collision for rigid bodies
func _push_away_rigid_bodies():
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		if collision.get_collider() is RigidBody3D:
			var push_dir = -collision.get_normal()
			
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - collision.get_collider().linear_velocity.dot(push_dir)
			
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			
			var approx_mass = 80.0
			var mass_ratio = min(1., approx_mass / collision.get_collider().mass)
			
			push_dir.y = 0
			
			var push_force = mass_ratio * 5.0
			collision.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, collision.get_position() - collision.get_collider().global_position)


func _physics_process(delta: float) -> void:
	#gets movement input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	#handles movement states
	
	#crouching
	if Input.is_action_pressed("crouch") || sliding:
		
		target_speed = lerp(target_speed, crouching_speed, delta * lerp_speed)
		head_pivot.position.y = lerp(head_pivot.position.y,crouch_depth, delta * lerp_speed)
		
		crouching_collision_shape.disabled = false
		standing_collision_shape.disabled = true
		
		#slide start logic
		
		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			print("Slide start")
			$Sounds/SlideSound.play()
		
		walking = false
		sprinting = false
		crouching = true
	
	#standing
	elif !ray_cast_3d.is_colliding():
		
		head_pivot.position.y = lerp(head_pivot.position.y, 0.0, delta * lerp_speed)
		crouching_collision_shape.disabled = true
		standing_collision_shape.disabled = false
		
		#sprinting
		if Input.is_action_pressed("sprint"):
			
			target_speed = lerp(target_speed, sprinting_speed, delta * lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		
		#walking
		else:
			target_speed = lerp(target_speed, walking_speed, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
	
	#handle freelook
	if Input.is_action_pressed("free_look"):
		free_looking = true
		eyes.rotation.z = -deg_to_rad(neck.rotation.y * free_look_tilt_amount)
		
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		eyes.rotation.z = lerp(neck.rotation.z, 0.0, delta * lerp_speed)
	
	#handle sliding
	if sliding:
		print(str(get_real_velocity().y))
		if get_real_velocity().y == 0:
			slide_timer -= delta/2
		elif get_real_velocity().y > 0 && is_on_floor():
			slide_timer -= delta * 2
		eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		if velocity.length() < 5 || !Input.is_action_pressed("crouch"):
			sliding = false
			free_looking = false
			$Sounds/SlideSound.stop()
			print("Slide end")
			if ray_cast_3d.is_colliding():
				crouching = true
				target_speed = crouching_speed
	
	#handle headbob
	headbob_time += delta * velocity.length() * float(is_on_floor()) * float(!sliding)
	eyes.transform.origin = headbob(headbob_time)
	
	#handle move tilt
	if input_dir != Vector2.ZERO && !(Input.is_action_pressed("left") && Input.is_action_just_pressed("right")):
		if Input.is_action_pressed("left"):
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(tilt_intensity), delta * 3)
		elif Input.is_action_pressed("right"):
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(-tilt_intensity), delta * 3)
	
	if !(Input.is_action_pressed("left") || Input.is_action_pressed("right")):
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * 3)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		if is_on_wall() == false:
			
			$Sounds/SlideSound.stop()
	else:
		wall_runnable = true

	# Handle jump.
	if (Input.is_action_just_pressed("jump") || jump_buffer) and ((((double_jump || coyote) && !is_on_wall())) || is_on_floor()):
		if is_on_floor() || jump_buffer || coyote:
			double_jump = true
		else:
			double_jump = false
			$Sounds/DoubleJump.play()
		velocity.y = jump_velocity
		direction += get_floor_normal() / 2
		target_speed += 2
		sliding = false
		$Sounds/SlideSound.stop()
		animation_player.play("jump")
		wall_runnable = false
		$Timers/WallRunTimer.start()
		jump_buffer = false
		
	#handle jump buffer
	if Input.is_action_just_pressed("jump") and !(is_on_floor() || is_on_wall()):
		$Timers/JumpBufferTimer.start()
		jump_buffer = true
	
	#coyote time
	if (is_on_floor() || is_on_wall()) && !coyote_buffer:
		$Timers/CoyoteTimer.start()
		coyote = true
	
	#handle landing
	if is_on_floor() && (last_velocity.y < 0.0):
		animation_player.play("landing")
		sprinting_speed = 15.0
		#print(str(last_velocity))
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	elif input_dir != Vector2.ZERO:
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		if slide_timer < 1.0:
			target_speed =  (slide_timer + 0.1) * slide_speed
		if slide_timer >= 1.0:
			if (abs(get_real_velocity().x) + abs(get_real_velocity().z) > target_speed):
				target_speed = slide_speed
	
	if direction:
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)
	
	last_velocity = velocity
	
	wall_run()
	_push_away_rigid_bodies()
	move_and_slide()
	
	print(str(target_speed))
	print(str(get_real_velocity()))
	
	#footstep sounds
	if not footstep_landed and is_on_floor(): #landed
		$Sounds/FootstepAudio3D.play()
		if sliding:
			$Sounds/SlideSound.play()
	elif footstep_landed and not is_on_floor(): #jumped
		$Sounds/FootstepAudio3D.play()
	footstep_landed = is_on_floor()
	
	

#headbob func
func headbob(headbob_time):
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude
	
	var footstep_threshold = -headbob_amplitude + .002
	if headbob_position.y > footstep_threshold:
		footstep_can_play = true
	elif headbob_position.y < footstep_threshold and footstep_can_play:
		footstep_can_play = false
		$Sounds/FootstepAudio3D.play()
	
	return headbob_position

#debug quit
func _process(_delta: float):
		if Input.is_action_pressed("quit"):
			get_tree().quit()


#slide sound loop
func _on_slide_sound_finished() -> void:
	$Sounds/SlideSound.play()

#wall run buffer
func _on_timer_timeout() -> void:
	wall_runnable = true


func _on_coyote_timer_timeout() -> void:
	coyote = false


func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false


func _on_coyote_buffer_timeout() -> void:
	coyote_buffer = false
