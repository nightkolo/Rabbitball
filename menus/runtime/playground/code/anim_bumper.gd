extends Button

@onready var bumper: Bumper = get_parent()

func _ready() -> void:
	pressed.connect(func():
		bumper.anim_bounce()
		)
