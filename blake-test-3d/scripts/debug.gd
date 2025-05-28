extends PanelContainer

@onready var property_container = $MarginContainer/VBoxContainer

#var property
var frames_per_second : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.debug = self
	
	visible = false

func _input(event: InputEvent) -> void:
	#toggle debug
	if event.is_action_pressed("debug"):
		visible = !visible

func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title,true,false) #tries to find label node with same name
	if !target: #if no current label node for property
		target = Label.new() #creates new label node
		property_container.add_child(target) #adds new node to VBox as child
		target.name = title #sets name to title
		target.text = target.name + ": " + str(value) #sets text value
	elif visible:
		target.text = title + ": " + str(value) #update text value
		property_container.move_child(target,order) #reorder property based on given order value

#func add_debug_property(title: String, value):
	#property = Label.new() #creates new label node
	#property_container.add_child(property) # adds node to VBox container as child
	#property.name = title #set name to given title
	#property.text = property.name + value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	add_property("FPS", frames_per_second, 1)
	if visible:
		frames_per_second = "%.2f" % (1.0/delta) #gets fps every frame
#		frames_per_second = Engine.get_frames_per_second() # gets fps every frame
		#property.text = property.name + ": " + frames_per_second
