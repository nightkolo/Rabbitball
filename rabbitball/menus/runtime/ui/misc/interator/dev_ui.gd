extends CanvasLayer


@onready var fps_label: Label = %"FPS Label"
@onready var delta_time_label: Label = %"deltaTime Label"

@onready var t_flip_avalue: Label = %"T_FLIP_A Label"
@onready var t_flip_bvalue: Label = %"T_FLIP_B Label"
@onready var flipper_a_blocks_onscreen_label: Label = %"flipper_A_blocks_onscreen Label"
@onready var flipper_b_blocks_onscreen_label: Label = %"flipper_B_blocks_onscreen Label"
@onready var flipper_a_movers_onscreen_label: Label = %"flipper_A_movers_onscreen Label"
@onready var flipper_b_movers_onscreen_label: Label = %"flipper_B_movers_onscreen Label"
@onready var level_name_label: Label = %"LEVEL_NAME Label"
@onready var level_id_label: Label = %"LEVEL_ID Label"
@onready var cabinet_id_label: Label = %"CABINET_ID Label"
@onready var menu_id_label: Label = %"MENU_ID Label"
@onready var auto_spawn_rb_label: Label = %"auto_spawn_rb Label"
@onready var current_cab_coordvalue: Label = %"current_cab_coord Label"
@onready var main: MarginContainer = $Main
@onready var arcade_id_label: Label = %"ARCADE_ID Label"

func _unhandled_input(_event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("reset_cabinet"):
		#UIMgr.game_reset.emit()


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	main.modulate = Color(Color.WHITE, 0.5)


func _process(delta: float) -> void:
	if self.visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
		delta_time_label.text = "delta: " + str(delta)
		t_flip_avalue.text = "T_FLIP_A: " + str(PlayerInput.T_FLIP_A)
		t_flip_bvalue.text = "T_FLIP_B: " + str(PlayerInput.T_FLIP_B)
		flipper_a_blocks_onscreen_label.text = "flipper_A_blocks_onscreen: " + str(RuntimeMgr.flipper_A_blocks_onscreen)
		flipper_b_blocks_onscreen_label.text = "flipper_B_blocks_onscreen: " + str(RuntimeMgr.flipper_B_blocks_onscreen)
		flipper_a_movers_onscreen_label.text = "flipper_A_movers_onscreen: "  + str(RuntimeMgr.flipper_A_movers_onscreen)
		flipper_b_movers_onscreen_label.text = "flipper_B_movers_onscreen: "  + str(RuntimeMgr.flipper_B_movers_onscreen)
		current_cab_coordvalue.text = "current_cab_coord: " + str(UIMgr.current_cab_coord)
		level_name_label.text = "LEVEL_NAME: " + str(UIMgr.LEVEL_NAME)
		arcade_id_label.text = "ARCADE_ID: " + str(UIMgr.ARCADE_ID) 
		level_id_label.text = "LEVEL_ID: " + str(UIMgr.LEVEL_ID)
		cabinet_id_label.text = "CABINET_ID: " + str(UIMgr.CABINET_ID)
		menu_id_label.text = "MENU_ID: " + str(UIMgr.MENU_ID)
		auto_spawn_rb_label.text = "auto_spawn_rabbitball: " + str(UIMgr.auto_spawn_rabbitball)
		
	else:
		self.set_process(false)
