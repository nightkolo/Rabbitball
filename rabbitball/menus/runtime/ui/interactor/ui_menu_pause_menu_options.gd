extends CanvasLayer

@onready var sound_btn: Button = %SoundButton
@onready var dynamic_camera_btn: Button = %DynamicCameraButton
@onready var back_btn: Button = %BackButton

var _ui_display: UIDisplay
var _tween: Tween


func _ready() -> void:
	visible = true
	hide()
	
	if get_parent() is UIDisplay:
		_ui_display = (get_parent() as UIDisplay)
	else:
		show_menu(true)
	
	if _ui_display:
		_ui_display.pause_menu_menu_changed.connect(func(is_menu: UIDisplay.PauseMenuMenus):
			match is_menu:
				
				UIDisplay.PauseMenuMenus.MAIN:
					show_menu(false)
					
				UIDisplay.PauseMenuMenus.OPTIONS:
					show_menu(true)
			)
	
	sound_btn.pressed.connect(func():
		var setting := UIMgr.get_game_audio_muted_setting()
		UIMgr.set_game_audio_muted(!setting)
		
		update_text()
		)
	dynamic_camera_btn.pressed.connect(func():
		var setting := UIMgr.get_dynamic_camera_on_setting()
		UIMgr.set_dynamic_camera(!setting)
		
		update_text()
		)
	back_btn.pressed.connect(func():
		if _ui_display:
			_ui_display.goto_pause_menu()
		)


func update_text() -> void:
	if UIMgr.get_game_audio_muted_setting():
		sound_btn.text = "Sounds: OFF"
	else:
		sound_btn.text = "Sounds: ON"
	
	if UIMgr.get_dynamic_camera_on_setting():
		dynamic_camera_btn.text = "Dynamic Camera: ON"
	else:
		dynamic_camera_btn.text = "Dynamic Camera: OFF"
	

func show_menu(show_m: bool) -> void:
	if show_m:
		Audio.ui_menu_enter.play()
		update_text()
		show()
		sound_btn.grab_focus()
	else:
		hide()
