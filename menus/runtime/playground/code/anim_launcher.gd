extends Button

@onready var launcher = get_parent()

func _ready() -> void:
	button_down.connect(func():
		launcher.hold_or_release(true)
		)
		
	button_up.connect(func():
		launcher.hold_or_release(false)
		)
		
