extends Control

@onready var button: Button = %Button


func _ready() -> void:
	button.pressed.connect(func():
		get_tree().change_scene_to_file("res://menus/main_menus_scene.tscn")
		)
