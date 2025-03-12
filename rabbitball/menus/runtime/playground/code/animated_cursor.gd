extends Node2D

@onready var held_cursor: Sprite2D = $Sprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_press"):
		held_cursor.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
	if event.is_action_released("mouse_press"):
		held_cursor.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(_delta: float) -> void:
	held_cursor.position = get_global_mouse_position() + Vector2(-3,-3)
