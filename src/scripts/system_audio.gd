extends Node

@onready var flipper_up: AudioStreamPlayer = $FlipperUp
@onready var flipper_down: AudioStreamPlayer = $FlipperDown
@onready var block_up: AudioStreamPlayer = $BlockUp
@onready var block_down: AudioStreamPlayer = $BlockDown
@onready var cabinet_reset: AudioStreamPlayer = $GameResetCabinet
@onready var game_cabinet_complete_jingles: Node = $GameCabinetCompleteJingles
@onready var arcade_complete: AudioStreamPlayer = $ArcadeComplete
@onready var arcade_1_startup_1: AudioStreamPlayer = $Arcade1Startup1
@onready var arcade_1_startup_2: AudioStreamPlayer = $Arcade1Startup2
@onready var ui_button_hover: AudioStreamPlayer = $UIButtonHover
@onready var ui_button_click: AudioStreamPlayer = $UIButtonClick
@onready var ui_menu_exit_2: AudioStreamPlayer = $UIMenuExit1
@onready var ui_menu_exit: AudioStreamPlayer = $UIMenuExit2
@onready var ui_menu_enter: AudioStreamPlayer = $UIMenuEnter
@onready var ui_option_toggle: AudioStreamPlayer = $UIOptionToggle
@onready var game_start: AudioStreamPlayer = $GameStart
@onready var game_paused: AudioStreamPlayer = $GamePaused
@onready var whoosh: AudioStreamPlayer = $Whoosh
@onready var swoosh: AudioStreamPlayer = $Swoosh
@onready var main_menu_trans: AudioStreamPlayer = $MainMenuTrans
@onready var letter_spin: AudioStreamPlayer = $LetterSpin

var next_cabinet_jingles: Array[Node]


func _ready() -> void:
	PlayerInput.flipper_A_touched.connect(emit_flipper_A_sound)
	PlayerInput.flipper_B_touched.connect(emit_flipper_B_sound)
	
	next_cabinet_jingles = game_cabinet_complete_jingles.get_children()
	
	#UIMgr.current_cabinet_coordinates_changed.connect(func(is_coord: Vector2):
		#whoosh.play()
		#)
	
	UIMgr.cabinet_completed.connect(func(_cab: int):
		var jingle: AudioStreamPlayer = next_cabinet_jingles[randi() % next_cabinet_jingles.size()]
		jingle.play()
		whoosh.play()
		)
	
	UIMgr.game_end.connect(func():
		arcade_complete.play()
		)


func emit_flipper_B_sound(is_held: bool) -> void:
	if RuntimeMgr.flipper_B_movers_onscreen > 0:
		if is_held:
			flipper_up.play()
		else:
			flipper_down.play()
			
	if RuntimeMgr.flipper_B_blocks_onscreen > 0:
		if is_held:
			block_up.play()
		else:
			block_down.play()
		
func emit_flipper_A_sound(is_held: bool) -> void:
	if RuntimeMgr.flipper_A_movers_onscreen > 0:
		if is_held:
			flipper_up.play()
		else:
			flipper_down.play()
			
	if RuntimeMgr.flipper_A_blocks_onscreen > 0:
		if is_held:
			block_up.play()
		else:
			block_down.play()


func emit_reset_sound() -> void:
	cabinet_reset.play()


func emit_game_start_sound() -> void:
	var rand := randi_range(0, 1)
	
	if rand > 0:
		arcade_1_startup_1.play()
	else:
		arcade_1_startup_2.play()


func emit_level_button_hover() -> void:
	var aud: AudioStreamPlayer = ui_button_click
	aud.pitch_scale = randf_range(0.9, 1.2)
	aud.play()
