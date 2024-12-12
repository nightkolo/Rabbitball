class_name OptionsScreen
extends MainMenu

@onready var op_btns: Array[Node] = get_tree().get_nodes_in_group("OptionButton")

@onready var sound_btn: Button = %SoundButton
@onready var dynamic_camera_btn: Button = %DynamicCameraButton
@onready var back_btn: Button = %BackButton

var _tween: Tween


func _ready() -> void:
	update_text()
	
	is_showing.connect(func():
		sound_btn.grab_focus()
		)
	
	back_btn.pressed.connect(func():
		back_button_pressed.emit()
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
		
	sound_btn.grab_focus()


func update_text() -> void:
	#await get_tree().create_timer(0.1).timeout
	if UIMgr.get_game_audio_muted_setting():
		sound_btn.text = "Sounds: OFF"
	else:
		sound_btn.text = "Sounds: ON"
	
	if UIMgr.get_dynamic_camera_on_setting():
		dynamic_camera_btn.text = "Dynamic Camera: ON"
	else:
		dynamic_camera_btn.text = "Dynamic Camera: OFF"
	
