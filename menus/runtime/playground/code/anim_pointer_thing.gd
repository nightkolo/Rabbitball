extends Button

@onready var parent: Node2D = get_parent()

var been_pressed: bool = false

func _ready() -> void:
	pressed.connect(func():
		been_pressed = !been_pressed
		
		if been_pressed:
			parent.anim_up()
		else:
			parent.anim_down()
		)
		
