extends CanvasLayer

@onready var btns = get_tree().get_nodes_in_group("UIButtons")

@onready var pause_info: RichTextLabel = %PauseInfo
@onready var resume_btn: Button = %ContinueButton
@onready var reset_btn: Button = %ResetCabinetButton
@onready var options_btn: Button = %OptionsButton
@onready var quit_btn: Button = %CreditsButton

var is_pause_menu_shown: bool:
	set(value):
		if value:
			UIMgr.MENU_ID = UIMgr.GameMenus.PAUSE_MENU
		else:
			UIMgr.MENU_ID = UIMgr.GameMenus.RUNTIME

var _ui_display: UIDisplay

const _INFO_BBCODE_STYLE = "[font_size=70][wave amp=50.0 freq=5.0 connected=10]"
const _PAUSE_INFO_BEGIN = _INFO_BBCODE_STYLE + "=Cabinet "
const _PAUSE_INFO_END = " Paused="


func _ready() -> void:
	visible = true
	hide()
	update_text()
	
	if get_parent() is UIDisplay:
		_ui_display = (get_parent() as UIDisplay)
	else:
		show_menu(true)
	
	UIMgr.level_info_updated.connect(update_text)
	
	if _ui_display:
		_ui_display.game_pause_toggled.connect(func(is_paused: bool):
			show_menu(is_paused)
			)
		_ui_display.pause_menu_menu_changed.connect(func(is_menu: UIDisplay.PauseMenuMenus):
			match is_menu:
				
				UIDisplay.PauseMenuMenus.MAIN:
					show_menu(true)
					
				UIDisplay.PauseMenuMenus.OPTIONS:
					show_menu(false)
			)
			
	resume_btn.pressed.connect(func():
		return_runtime()
		Audio.game_start.play()
		)
	reset_btn.pressed.connect(func():
		return_runtime()
		if _ui_display:
			_ui_display.reset_cabinet()
		)
	options_btn.pressed.connect(func():
		if _ui_display:
			_ui_display.goto_options_menu()
		)
	quit_btn.pressed.connect(func():
		if _ui_display:
			_ui_display.allow_input = false
		Audio.ui_menu_exit.play()
		return_runtime()
		Trans.sidebars_to_scene("res://menus/main_menus_scene.tscn", 1.2, 1.2, 0.1)
		)
	
	resume_btn.grab_focus()


func update_text() -> void:
	if UIMgr.LEVEL_NAME == &"Intro":
		pause_info.text = _INFO_BBCODE_STYLE + "=Intro Paused="
	else:
		pause_info.text = _PAUSE_INFO_BEGIN + UIMgr.LEVEL_NAME + _PAUSE_INFO_END


func return_runtime() -> void:
	if _ui_display:
		_ui_display.return_runtime()


func show_menu(show_m: bool) -> void:
	is_pause_menu_shown = show_m
	
	if show_m:
		Audio.game_paused.play()
		show()
		resume_btn.grab_focus()
	else:
		hide()
