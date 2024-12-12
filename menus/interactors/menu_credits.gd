extends Control

@onready var back_btn: Button = %BackButton


func _ready() -> void:
	UIMgr.MENU_ID = UIMgr.GameMenus.CREDITS
	
	back_btn.pressed.connect(func():
		Trans.sidebars_to_scene("res://menus/main_menus_scene.tscn")
		)
		
	#back_btn.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_cancel"):
		back_btn.grab_focus()
