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
@onready var interaction = $Model/neck/headPivot/interaction_raycast
@onready var hand = $Model/neck/headPivot/hand
@onready var grab_joint = $Model/neck/headPivot/grab_joint
@onready var grab_body = $Model/neck/headPivot/grab_body
@onready var step_detector_raycast = $feet_collision/step_detector_raycast
@onready var step_height_raycast = $feet_collision/step_height_raycast
@onready var step_max_raycast = $feet_collision/step_max_raycast
@onready var health_bar = $UserInterface/ProgressBar

#sound vars
@onready var slide_sound = $Sounds/SlideSound
@onready var footstep_sound = $Sounds/FootstepAudio3D
@onready var wall_jump_sound = $Sounds/WallSound
@onready var double_jump_sound = $Sounds/DoubleJump

#speed vars
var target_speed := 5.0
@export var walking_speed := 7.5
@export var sprinting_speed := 15.0
@export var crouching_speed := 5.0
var air_dash_speed = 40

#states
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#slide vars
var slide_timer := 0.5
var slide_timer_max := 1.5
var slide_vector := Vector2.ZERO
var slide_speed := 15.0

#head bobbing vars
@export var headbob_frequency := 1.75
@export var headbob_amplitude := .04
var headbob_time := 0.0
var footstep_can_play := true
var footstep_landed

#move tilt vars
var tilt_intensity := 15.0

#movement vars
@export var jump_velocity := 9
var lerp_speed := 10.0
var acceleration := 10.0 
var air_acceleration := 5
var deceleration := 15.0
var crouch_depth := -.6 
var free_look_tilt_amount := 4.0
var air_lerp_speed := 3.0
var last_velocity := Vector3.ZERO
var wall_friction := .9
var wall_runnable := false
var coyote := false
var jump_buffer := false
var double_jump := false
var coyote_buffer := false
var last_velo := 0.0
var wall_jumped := false
var slid_velo := 0.0
var speed_fov_change := 15.0
var wall_running = false
var air_dashing = false
var wish_dir := Vector3.ZERO
var cam_aligned_wish_dir := Vector3.ZERO
var noclip_speed_mult := 2.0
var noclip := false

#input vars
var direction := Vector3.ZERO
var mouse_free := false

#recoil vars
var target_recoil := Vector2.ZERO
var current_recoil := Vector2.ZERO
const RECOIL_APPLY_SPEED : float = 10.0
const RECOIL_RECOVER_SPEED : float = 7.0

#grab vars
var grabbed_object
var pull_power = 25.0
var rotation_power = .05
var mouse_locked = false
var throw_power = 25

var iframes = false
var health = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	#mouse looking logic
	if event is InputEventMouseMotion && !mouse_locked:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * MouseSensitivity.check_mouse_sens()))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * MouseSensitivity.check_mouse_sens()))
		head_pivot.rotate_x(deg_to_rad(-event.relative.y * MouseSensitivity.check_mouse_sens()))
		head_pivot.rotation.x = clamp(head_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	#flashlight logic
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	
	#frees mouse
	if Input.is_action_just_pressed("mouse_free"):
		if !mouse_free:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_free = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_free = false
	
	#grab object
	if Input.is_action_just_pressed("grab"):
		if (interaction.get_collider() != null) && (interaction.get_collider().is_in_group("button")):
			print("press sent")
			interaction.get_collider().pressed()
		else:
			if grabbed_object != null:
				drop_object()
			else:
				grab_object()
	
	#rotate object
	if Input.is_action_pressed("rotate"):
		mouse_locked = true
		rotate_object(event)
	if Input.is_action_just_released("rotate"):
		mouse_locked = false
	
	#throw object
	if Input.is_action_just_pressed("throw"):
		if grabbed_object != null:
			var throw_force = grabbed_object.global_position - head_pivot.global_position
			grabbed_object.apply_central_impulse(throw_force * throw_power * sqrt(grabbed_object.mass))
			drop_object()

#grabbing
func grab_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D and collider.is_in_group("grabbable"):
		print("colliding with a rigid body")
		grabbed_object = collider
		grab_joint.set_node_b(grabbed_object.get_path())

func drop_object():
	if grabbed_object != null:
		grabbed_object = null
		grab_joint.set_node_b(grab_joint.get_path())

func rotate_object(event):
	if grabbed_object != null:
		if event is InputEventMouseMotion:
			grab_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			grab_body.rotate_y(deg_to_rad(event.relative.x * rotation_power))

#wall run and jump logic
func wall_run(delta):
	if is_on_wall_only():
		var wall_normal = get_slide_collision(0).get_normal()
		var wall_forward = Vector3.UP.cross(wall_normal).normalized()
		var dot = wall_forward.dot(direction.normalized())
		#wall run check
		if is_on_wall_only() and wall_runnable and Input.is_action_pressed("sprint") and !(dot < .2 and dot > -.2) and !sliding:
			print(str(dot))
			if dot > .2:
				print("1")
				eyes.rotation.z = lerp((transform.basis * eyes.rotation).z, deg_to_rad(-360), delta / 2)
			else:
				print("2")
				eyes.rotation.z = lerp((transform.basis * eyes.rotation).z, deg_to_rad(360), delta / 2)
			if !wall_jump_sound.playing:
				wall_jump_sound.play()
			target_speed = 20.0
			velocity.y *= .95
			double_jump = true
			wall_running = true
			direction += -get_wall_normal() * .005
			#wall jump
			if (Input.is_action_just_pressed("jump") || jump_buffer) && !wall_jumped:
				coyote_buffer = true
				$Timers/CoyoteBuffer.start()
				footstep_sound.play()
				slide_sound.stop()
				direction = get_wall_normal() * .5
				velocity.y = jump_velocity
				jump_buffer = false
				wall_jumped = true
				$Timers/WallJumped.start()
				wall_running = false
		else:
			wall_jump_sound.stop()
			wall_running = false
	else:
		wall_jump_sound.stop()
		wall_running = false

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
			
			var push_force = mass_ratio * 3
			collision.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, collision.get_position() - collision.get_collider().global_position)


func _physics_process(delta: float) -> void:
	#gets movement input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	Global.debug.add_property("target_speed", target_speed, 3)
	Global.player = self
	Global.debug.add_property("velocity", velocity.length(), 4)
	Global.debug.add_property("horizontal_velocity", Vector2(velocity.x, velocity.z).length(), 4)
	Global.debug.add_property("slide_timer", slide_timer, 5)
	
	#handles movement states
	
	#crouching
	if Input.is_action_pressed("crouch") || sliding && !noclip:
		
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
			slide_sound.play()
		
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
	
	#handle slide slowdown and ending
	if sliding:
		print(str(get_real_velocity().y))
		if get_real_velocity().y == 0:
			slide_timer -= delta / 2
		elif get_real_velocity().y > 0 && is_on_floor():
			slide_timer -= delta * 2
		eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		if velocity.length() < 5 || !Input.is_action_pressed("crouch"):
			sliding = false
			free_looking = false
			slide_sound.stop()
			print("Slide end")
			if ray_cast_3d.is_colliding():
				crouching = true
				target_speed = crouching_speed
	
	#handle headbob
	if !noclip:
		headbob_time += delta * velocity.length() * float(is_on_floor()) * float(!sliding)
		eyes.transform.origin = headbob(headbob_time)
	
	#handle move tilt
	if input_dir != Vector2.ZERO && !(Input.is_action_pressed("left") && Input.is_action_just_pressed("right")) && !is_on_wall():
		if Input.is_action_pressed("left"):
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(tilt_intensity), delta * 3)
		elif Input.is_action_pressed("right"):
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(-tilt_intensity), delta * 3)
	
	if !(Input.is_action_pressed("left") || Input.is_action_pressed("right")) && !is_on_wall():
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * 3)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		if is_on_wall() == false:
			
			slide_sound.stop()
	else:
		wall_runnable = true
	
	# Handle jump.
	if (Input.is_action_just_pressed("jump") || jump_buffer) and ((((double_jump || coyote) && !wall_running)) || is_on_floor()) && !noclip:
		if is_on_floor() || jump_buffer || coyote:
			double_jump = true
		else:
			double_jump = false
			double_jump_sound.play()
		last_velo = target_speed
		last_velo += .5
		velocity.y = jump_velocity
		direction += get_floor_normal() / 2
		slide_sound.stop()
		animation_player.play("jump")
		wall_runnable = false
		if wall_runnable:
			direction = direction.normalized() * (direction.length() + 1)
		$Timers/WallRunTimer.start()
		jump_buffer = false
	
	
	#handle jump buffer
	if Input.is_action_just_pressed("jump") and !(is_on_floor() || is_on_wall()):
		$Timers/JumpBufferTimer.start()
		jump_buffer = true
	
	#coyote time
	if (is_on_floor() || wall_running) && !coyote_buffer:
		$Timers/CoyoteTimer.start()
		coyote = true
	
	#handle landing
	if is_on_floor() && (last_velocity.y < 0.0) && !noclip:
		if !sliding:
			direction.z *= .75
			direction.x *= .75
		animation_player.play("landing")
		sprinting_speed = 15.0
		slide_timer = slide_timer_max
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor() and !air_dashing:
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	elif input_dir != Vector2.ZERO:
		#if wall_jumped:
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_acceleration)
		#else:
		#	direction = (lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_acceleration)).normalized()
		#direction = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	
	#handle air dash
	#if Input.is_action_just_pressed("air_dash") || air_dashing:
	#	target_speed = air_dash_speed
	#	if $Timers/air_dashing.is_stopped():
	#		$Timers/air_dashing.start()
	#		air_dashing = true
	
	#handle object grabbing
	if grabbed_object != null:
		var obj_location = grabbed_object.global_transform.origin
		var hand_location = hand.global_transform.origin
		var obj_distance = obj_location.distance_to(hand_location)
		grabbed_object.set_linear_velocity((hand_location - obj_location) * (pull_power * (obj_distance / grabbed_object.mass) * (sqrt(grabbed_object.mass) / 2)))
		if (obj_location - hand_location).length() > 3:
			drop_object()
	
	#slide movement
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		if slide_timer < 1:
			target_speed =  (slide_timer) * last_velo
		if slide_timer >= 1:
			if (abs(get_real_velocity().x) + abs(get_real_velocity().z) > target_speed):
				target_speed = last_velo
	
	#checks for noclip
	if not _handle_noclip(delta):
		#maintins velocity while sliding or airborne
		if direction:
			if !is_on_floor() || (sliding and slide_timer > 1.0) and !air_dashing:
				velocity.x = direction.x * last_velo
				velocity.z = direction.z * last_velo
				target_speed = last_velo
			else:
				velocity.x = direction.x * target_speed
				velocity.z = direction.z * target_speed
				if !sliding:
					last_velo = Vector2(velocity.x, velocity.z).length()
			
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration)
			velocity.z = move_toward(velocity.z, 0, deceleration)
		
		#step-up
		#if !sliding && !wall_running && is_on_floor():
		#	if step_detector_raycast.is_colliding() && !step_max_raycast.is_colliding() && (Vector2(velocity.x, velocity.z).length() > 1 && Input.is_action_pressed("forward")):
		#		print("attempt")
		#		var step_height = .5 + step_detector_raycast.get_collision_point().y - step_height_raycast.get_collision_point().y
		#		print(str(step_height))
		#		position = position.move_toward(Vector3(position.x, position.y + step_height, position.z), step_height)
		
		#run movement functions
		wall_run(delta)
		_push_away_rigid_bodies()
		move_and_slide()
	
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	cam_aligned_wish_dir = %Camera3D.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	last_velocity = velocity
	
	
	#footstep sounds
	if not footstep_landed and is_on_floor(): #landed
		if sliding:
			slide_sound.play()
		else:
			footstep_sound.play()
	elif footstep_landed and not is_on_floor(): #jumped
		footstep_sound.play()
	footstep_landed = is_on_floor()

##noclip
func _handle_noclip(delta) -> bool:
	if Input.is_action_just_pressed("_noclip"):
		noclip = !noclip
	if !crouching:
		standing_collision_shape.disabled = noclip
		crouching_collision_shape.disabled = !noclip
	else:
		crouching_collision_shape.disabled = noclip
		standing_collision_shape.disabled = !noclip
	
	if not noclip:
		return false
	
	var speed = walking_speed
	if Input.is_action_pressed("sprint"):
		speed = sprinting_speed
	
	self.velocity = cam_aligned_wish_dir * speed * noclip_speed_mult
	global_position += self.velocity * delta
	
	return true

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
		footstep_sound.play()
	
	return headbob_position

#recoil
func add_recoil(pitch: float, yaw: float) -> void:
	target_recoil.x += pitch
	target_recoil.y += yaw

func update_recoil(delta: float) -> void:
	target_recoil = target_recoil.lerp(Vector2.ZERO, RECOIL_APPLY_SPEED * delta)
	
	var prev_recoil = current_recoil
	current_recoil = current_recoil.lerp(target_recoil, RECOIL_APPLY_SPEED * delta)
	var recoil_difference = current_recoil - prev_recoil
	
	rotate_y(recoil_difference.y)
	%Camera3D.rotate_x(recoil_difference.x)
	%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

#handles player damage
func take_damage(amount):
	print(iframes)
	if !iframes:
		iframes = true
		health -= amount
		print(health)
		if health < 0:
			pass
		else:
			health_bar.value = health
		$Timers/iframe_timer.start()
	return

#adds property for alternate sounds to debug menu
func _process(_delta: float):
	Global.debug.add_property("alt_sounds", AltSounds.alt_sounds_check(), 6)

#slide sound loop
func _on_slide_sound_finished() -> void:
	slide_sound.play()

#wall run buffer
func _on_timer_timeout() -> void:
	wall_runnable = true

#coyote time timer
func _on_coyote_timer_timeout() -> void:
	coyote = false

#jump buffer
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false

#coyote time buffer
func _on_coyote_buffer_timeout() -> void:
	coyote_buffer = false

#wall jump buffer
func _on_wall_jumped_timeout() -> void:
	wall_jumped = false


func _on_air_dashing_timeout() -> void:
	air_dashing = false


func _on_iframe_timer_timeout() -> void:
	print('iframes ended')
	iframes = false
	print(iframes)
