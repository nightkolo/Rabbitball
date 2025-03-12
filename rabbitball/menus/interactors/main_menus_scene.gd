class_name MainMenusUI
extends Control

@export var transition_time: float = 0.7

@onready var menus: Array[Node] = get_tree().get_nodes_in_group("MenuScreen")

@onready var ui_cam: Camera2D = $UICam

@onready var menu_title: TitleScreen = $MenuTitle
#@onready var menu_credits: CreditsScreen = $MenuCredits
@onready var menu_cabinet_select: CabinetSelectScreen = $MenuCabinetSelect
@onready var menu_options: OptionsScreen = $OptionsMenu

var _tween_cam: Tween
var _tween_fade_out: Tween
var _tween_fade_in: Tween


func _ready() -> void:
	UIMgr.MENU_ID = UIMgr.GameMenus.TITLE
	
	menu_title.credits_btn_pressed.connect(func():
		Trans.sidebars_to_scene("res://menus/menu_credits.tscn")
		)
	
	menu_title.select_cabinet_btn_pressed.connect(func():
		enter_main_menu(UIMgr.GameMenus.CABINET_SELECT)
		)
	
	menu_title.options_btn_pressed.connect(func():
		enter_main_menu(UIMgr.GameMenus.OPTIONS)
		)
	
	for menu: MainMenu in menus:
		menu.back_button_pressed.connect(func():
			enter_main_menu(UIMgr.GameMenus.TITLE)
		)


func enter_main_menu(p_menu: UIMgr.GameMenus) -> void:
	UIMgr.MENU_ID = p_menu
	
	enter_menu(p_menu)
	trans_cam_to_menu_pos(p_menu)


func enter_menu(p_menu: UIMgr.GameMenus) -> void:
	_disable_menu_buttons(menus)
	
	await _anim_fade_out()
	_reset_tween_fade_in()
	_tween_fade_in = get_tree().create_tween()
	
	match p_menu:
		
		UIMgr.GameMenus.TITLE:
			menu_title.show()
			menu_title.visible = true
			_tween_fade_in.tween_property(menu_title.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
		
		UIMgr.GameMenus.CABINET_SELECT:
			menu_cabinet_select.show()
			menu_cabinet_select.visible = true
			_tween_fade_in.tween_property(menu_cabinet_select.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
		UIMgr.GameMenus.CREDITS:
			pass
			#menu_credits.show()
			#menu_credits.visible = true
			#_tween_fade_in.tween_property(menu_credits.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
		UIMgr.GameMenus.OPTIONS:
			menu_options.show()
			menu_options.visible = true
			_tween_fade_in.tween_property(menu_options.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
		_:
			pass
			
	#await get_tree().create_timer(0.4).timeout
	_disable_menu_buttons(menus, false)


func trans_cam_to_menu_pos(p_menu: UIMgr.GameMenus) -> void:
	Audio.main_menu_trans.play()
	match p_menu:
		
		UIMgr.GameMenus.TITLE:
			_anim_move_cam(Vector2.ZERO)
		
		UIMgr.GameMenus.CABINET_SELECT:
			_anim_move_cam(Vector2(0.0, 720.0))
			
		UIMgr.GameMenus.CREDITS:
			#_anim_move_cam(Vector2(-900.0, 0.0))
			pass
			
		UIMgr.GameMenus.OPTIONS:
			_anim_move_cam(Vector2(900.0, 0.0))


func _anim_fade_out() -> void:
	_reset_tween_fade_out()
	_tween_fade_out = get_tree().create_tween().set_parallel(true)
	_tween_fade_out.tween_property(menu_title.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2.0)
	_tween_fade_out.tween_property(menu_cabinet_select.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2.0)
	#_tween_fade_out.tween_property(menu_credits.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2.0)
	_tween_fade_out.tween_property(menu_options.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2)
	await _tween_fade_out.finished
	for menu: MainMenu in menus:
		menu.hide()
		menu.visible = false


func _anim_move_cam(move_to: Vector2) -> void:
	_reset_tween_cam()
	_tween_cam = get_tree().create_tween()
	_tween_cam.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_cam.tween_property(ui_cam,"global_position",move_to,transition_time)


func _disable_menu_buttons(p_menus: Array[Node], disable: bool = true) -> void:
	for menu: MainMenu in p_menus:
		for btn: Button in menu.btns:
			btn.disabled = disable


func _reset_tween_cam() -> void:
	if _tween_cam != null:
		_tween_cam.kill()
		
		
func _reset_tween_fade_out() -> void:
	if _tween_fade_out != null:
		_tween_fade_out.kill()
		

func _reset_tween_fade_in() -> void:
	if _tween_fade_in != null:
		_tween_fade_in.kill()
