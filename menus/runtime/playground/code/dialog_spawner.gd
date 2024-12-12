extends Marker2D

@export var lines: Array[String] = [
	"Hello there",
	"Kolo needs to rest a bit",
	"In the meantime, let's test if this dialog bubble system is well and working!",
	"Anyhooooo, goodnight...",
	"Bye.",
	":3"
]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_press"):
		RuntimeMgr.start_dialog(global_position, lines)
