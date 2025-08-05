class_name WeaponResource
extends Resource

#currently only model used
@export var view_model : PackedScene
#world model in case that becomes necessary
#@export var world_model : PackedScene

@export var view_model_pos : Vector3
@export var view_model_rot : Vector3
@export var view_model_scale := Vector3(1,1,1)

@export var view_idle_anim : String
@export var view_equip_anim : String
@export var view_shoot_anim : String
@export var view_reload_anim : String

@export var slide_idle_anim : String
@export var slide_equip_anim : String
@export var slide_shoot_anim : String
@export var slide_reload_anim : String

@export var to_slide_anim : String
@export var from_slide_anim : String

#sounds

@export var shoot_sound : AudioStream
@export var reload_sound : AudioStream
@export var unholster_sound : AudioStream

@export var alt_shoot_sound : AudioStreamRandomizer
@export var alt_reload_sound : AudioStream
@export var alt_unholster_sound : AudioStream


#weapon logic

@export var damage : float

@export var current_ammo := INF
@export var magazine_capacity := INF
@export var reserve_ammo := INF
@export var max_reserve_ammo := INF

@export var auto_fire := true
@export var max_fire_rate_ms := 50.0

const RAYCAST_DIST : float = 9999 #cant really go farther

var weapon_manager : WeaponManager

#player sliding storage
var player_sliding := false

#shooting and equip logic
var trigger_down := false :
	set (v):
		if trigger_down != v:
			trigger_down = v
			if trigger_down:
				on_trigger_down()
			else:
				on_trigger_up()

var is_equipped := false : 
	set(v):
		if is_equipped != v:
			is_equipped = v
			if is_equipped:
				on_equip()
			else:
				on_unequip()

var last_fire_time = -999999

func on_process(delta : float) -> void:
	if trigger_down and auto_fire and Time.get_ticks_msec() - last_fire_time > max_fire_rate_ms:
		if current_ammo > 0:
			fire_shot()
		else:
			reload_pressed()

#shooting and equip functions
func on_trigger_down():
	if Time.get_ticks_msec() - last_fire_time >= max_fire_rate_ms and current_ammo > 0:
		fire_shot()
	elif current_ammo == 0:
		reload_pressed()
	print("trigger_down")

func on_trigger_up():
	pass

func on_equip():
	if player_sliding:
		weapon_manager.play_animation(slide_equip_anim)
		weapon_manager.queue_animation(slide_idle_anim)
	else:
		weapon_manager.play_animation(view_equip_anim)
		weapon_manager.queue_animation(view_idle_anim)

func on_unequip():
	pass

func get_amount_can_reload() -> int:
	var wish_reload = magazine_capacity - current_ammo
	var can_reload = min(wish_reload, reserve_ammo)
	return can_reload

func reload_pressed():
	if (view_reload_anim || slide_reload_anim) and ((weapon_manager.get_anim() == view_reload_anim) || ( weapon_manager.get_anim() == slide_reload_anim)):
		return
	if get_amount_can_reload() <= 0:
		return
	var cancel_cb = (func(): 
		weapon_manager.stop_sounds())
	if player_sliding:
		weapon_manager.play_animation(slide_reload_anim, reload, cancel_cb)
		weapon_manager.queue_animation(slide_idle_anim)
	else:
		weapon_manager.play_animation(view_reload_anim, reload, cancel_cb)
		weapon_manager.queue_animation(view_idle_anim)
	if AltSounds.alt_sounds_on:
		weapon_manager.play_sound(alt_reload_sound, "reload")
	else:
		weapon_manager.play_sound(reload_sound, "reload")

func reload():
	var can_reload = get_amount_can_reload()
	print("reload ran")
	if can_reload <= 0:
		print("can't reload")
		return
	elif magazine_capacity == INF or current_ammo == INF:
		print("ammo updated")
		current_ammo = magazine_capacity
	else:
		print("reload updated")
		current_ammo += can_reload
		reserve_ammo -= can_reload

#shooting logic
func fire_shot():
	weapon_manager.stop_sound("reload")
	if AltSounds.alt_sounds_on:
		weapon_manager.play_sound(alt_shoot_sound, "shot")
	else:
		weapon_manager.play_sound(shoot_sound, "shot")
	
	if player_sliding:
		weapon_manager.play_animation(slide_shoot_anim)
	else:
		weapon_manager.play_animation(view_shoot_anim)
	
	if player_sliding:
		weapon_manager.queue_animation(slide_idle_anim)
	else:
		weapon_manager.queue_animation(view_idle_anim)
	
	var raycast = weapon_manager.bullet_raycast
	raycast.target_position = Vector3(0,0,-abs(RAYCAST_DIST))
	raycast.force_raycast_update()
	
	var bullet_target = raycast.global_transform * raycast.target_position
	if raycast.is_colliding():
		var object = raycast.get_collider()
		var normal = raycast.get_collision_normal()
		var point = raycast.get_collision_point()
		bullet_target = point
		BulletDecalPool.spawn_bullet_decal(point, normal, object, raycast.global_basis)
		if !object.is_in_group("character"):
			if object is RigidBody3D:
				object.apply_impulse(-normal * 15.0 / object.mass, point - object.global_position)
			if object.has_method("take_damage"):
				object.take_damage(self.damage)
	
	weapon_manager.show_muzzle_flash()
	weapon_manager.make_bullet_trail(bullet_target)
	
	last_fire_time = Time.get_ticks_msec()
	current_ammo -= 1

func started_sliding():
	weapon_manager.queue_animation(to_slide_anim)
	weapon_manager.queue_animation(slide_idle_anim)
	player_sliding = true

func stopped_sliding():
	weapon_manager.queue_animation(from_slide_anim)
	weapon_manager.queue_animation(view_idle_anim)
	player_sliding = false
