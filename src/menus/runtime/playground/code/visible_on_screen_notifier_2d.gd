extends VisibleOnScreenNotifier2D


func _ready() -> void:
	screen_entered.connect(func():
		print("screen_entered")
		)
	screen_exited.connect(func():
		print("screen_exited")
		)
