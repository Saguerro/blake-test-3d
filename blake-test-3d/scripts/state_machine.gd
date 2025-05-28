class_name state_machine

extends Node

@export var current_state : State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
		else:
			push_warning("State machine contains incompatible child node")
	current_state.enter()

func _process(delta: float):
	current_state.update(delta)
	Global.debug.add_property("Current State",current_state.name,3)

func _physics_process(delta: float):
	current_state.physics_update(delta)

func on_child_transition(new_state_name: StringName):
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != current_state:
			current_state.exit()
			new_state.enter()
			current_state = new_state
	else:
		push_warning("State does not exist")
