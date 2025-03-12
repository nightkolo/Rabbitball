extends Button

@onready var switch: Switch = get_parent()

var been_pressed: bool = false

func _ready() -> void:
	pressed.connect(func():
		been_pressed = !been_pressed
		
		if been_pressed:
			switch.anim_hit()
		else:
			switch.anim_unhit() # Good method name.
		
		)
