extends Button

@onready var door: Door = get_parent()

func _ready() -> void:
	pressed.connect(func():
		door.is_actiavated = !door.is_actiavated
		
		if door.is_actiavated:
			door._anim.play("on") # Wait, that's illegal
		else:
			door._anim.play("off")
		
		)
