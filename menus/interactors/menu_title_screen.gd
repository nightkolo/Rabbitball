class_name TitleScreen
extends MainMenu

signal start_btn_pressed()
signal options_btn_pressed()
signal select_cabinet_btn_pressed()
signal credits_btn_pressed()

@onready var start_btn: Button = %StartButton
@onready var options_btn: Button = %OptionsButton
@onready var select_cab_btn: Button = %SelectCabinetButton
@onready var cred_btn: Button = %CreditsButton


func _ready() -> void:
	start_btn.call_deferred("grab_focus") # It works, but why??
	
	is_showing.connect(func():
		start_btn.grab_focus()
		)
	
	start_btn.pressed.connect(start_game)
	select_cab_btn.pressed.connect(goto_select_cabinet)
	options_btn.pressed.connect(goto_options)
	cred_btn.pressed.connect(goto_credits)
	

func start_game() -> void:
	start_btn_pressed.emit()
	Audio.game_start.play()
	UIMgr.hello_from_the_cabinet_select_screen = true
	UIMgr.LEVEL_ID = 101
	disable_buttons(btns)
	await get_tree().create_timer(0.25).timeout
	Trans.bars_to_scene("res://menus/runtime/levels/world_1.tscn", 1.0, 0.8, 0.2)


func goto_select_cabinet() -> void:
	select_cabinet_btn_pressed.emit()


func goto_credits() -> void:
	credits_btn_pressed.emit()
	

func goto_options() -> void:
	options_btn_pressed.emit()
