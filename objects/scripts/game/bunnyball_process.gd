## Must be a child of [Bunnyball].
extends VisibleOnScreenNotifier2D

@export var change_bunnyball: bool = true

@onready var bunnyball: Bunnyball = get_parent()


func _ready() -> void:
	if !bunnyball.always_process:
		set_bunnyball_process()
	
	
func set_bunnyball_process() -> void:
	if change_bunnyball:
		bunnyball.freeze = true
		
		screen_entered.connect(func():
			bunnyball.freeze = false
			)
			
		screen_exited.connect(func():
			bunnyball.freeze = true
			)
		
