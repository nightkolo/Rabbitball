extends VisibleOnScreenNotifier2D

func _ready() -> void:
	screen_entered.connect(func():
		(get_parent() as Bunnyball).freeze = false
		)
	
