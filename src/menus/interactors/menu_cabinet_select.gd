## Glorified LevelSelectScreen.
class_name CabinetSelectScreen
extends MainMenu

@onready var cab_btns: Array[Node] = get_tree().get_nodes_in_group("CabinetButton")

@onready var btn_c_1: Button = %BtnC1
@onready var back_btn: Button = %BackButton


func _ready() -> void:
	is_showing.connect(func():
		btn_c_1.grab_focus()
		)
	
	back_btn.pressed.connect(func():
		back_button_pressed.emit()
		)
	
	for cab_btn: Button in cab_btns:
		cab_btn.pressed.connect(func():
			goto_level(cab_btn.name.to_int())
			)
			
	btn_c_1.grab_focus()


func goto_level(level_id: int) -> void:
	var init_id := UIMgr.LEVEL_ID
	
	disable_buttons(btns)
	UIMgr.hello_from_the_cabinet_select_screen = true
	UIMgr.LEVEL_ID = level_id
	
	if (level_id >= 1 && level_id <= 10):
		_goto_arcade1()
		
	elif (level_id >= 11 && level_id <= 20):
		_goto_arcade2()
		
	else:
		print('"Cabinet A-' + str(level_id) + '" is non-existent :(')
		UIMgr.LEVEL_ID = init_id
		UIMgr.hello_from_the_cabinet_select_screen = false
		disable_buttons(btns, false)
		
	

func _goto_arcade1() -> void:
	Trans.bars_to_scene("res://menus/runtime/levels/world_1.tscn", 1.5, 1.0, 0.5)
	

func _goto_arcade2() -> void:
	Trans.bars_to_scene("res://menus/runtime/levels/world_2.tscn", 1.5, 1.0, 0.5)
