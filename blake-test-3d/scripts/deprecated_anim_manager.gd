extends AnimationPlayer

var states = {
	"Idle_unarmed":["Kinfe_equip", "Pistol_equip", "Rifle_equip", "Idle_unarmed"],
	
	"Pistol_equip":["Pistol_idle"],
	"Pistol_fire":["Pistol_idle"],
	"Pistol_idle":["Pistol_fire", "Pistol_reload", "Pistol_unequip", "Pistol_idle"],
	"Pistol_reload":["Pistol_idle"],
	"Pistol_unequip":["Idle_unarmed"],

	"Rifle_equip":["Rifle_idle"],
	"Rifle_fire":["Rifle_idle"],
	"Rifle_idle":["Rifle_fire", "Rifle_reload", "Rifle_unequip", "Rifle_idle"],
	"Rifle_reload":["Rifle_idle"],
	"Rifle_unequip":["Idle_unarmed"],

	"Knife_equip":["Knife_idle"],
	"Knife_fire":["Knife_idle"],
	"Knife_idle":["Knife_fire", "Knife_unequip", "Knife_idle"],
	"Knife_unequip":["Idle_unarmed"]
}

var animation_speeds = {
	"Idle_unarmed":1,

	"Pistol_equip":1.4,
	"Pistol_fire":1.8,
	"Pistol_idle":1,
	"Pistol_reload":1,
	"Pistol_unequip":1.4,

	"Rifle_equip":2,
	"Rifle_fire":6,
	"Rifle_idle":1,
	"Rifle_reload":1.45,
	"Rifle_unequip":2,

	"Knife_equip":1,
	"Knife_fire":1.35,
	"Knife_idle":1,
	"Knife_unequip":1
}

var current_state = null
var callback_function = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_animation("Idle_unarmed")
	self.animation_finished.connect(self.animation_ended)

func set_animation(animation_name):
	if animation_name == current_state:
		print("animation_player_manager -- WARNING: animation is already ", animation_name)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
