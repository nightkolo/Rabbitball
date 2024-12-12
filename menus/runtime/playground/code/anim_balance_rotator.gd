extends Button

@onready var flipper: FlipperRotator = get_parent()

var been_pressed: bool = false

func _ready() -> void:
	pressed.connect(func():
		been_pressed = !been_pressed
		
		PlayerInput.FLIP_B_HELD = been_pressed
		)
		
