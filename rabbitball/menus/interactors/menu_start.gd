extends Control

@onready var start_btn: Button = %StartButton
@onready var ver_label: Label = %VerLabel


func _ready() -> void:
	start_btn.grab_focus()
	
	ver_label.text = UIMgr.game_current_version_text
	
	start_btn.pressed.connect(start_game)


func start_game() -> void:
	Audio.game_start.play()
	start_btn.disabled = true
	UIMgr.hello_from_the_cabinet_select_screen = true
	UIMgr.LEVEL_ID = 101
	Trans.bars_to_scene("res://menus/runtime/levels/world_1.tscn", 1.0, 0.8, 0.2)
