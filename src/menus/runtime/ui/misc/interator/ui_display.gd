class_name UIDisplay
extends CanvasLayer

signal game_pause_toggled(is_paused: bool)
signal pause_menu_menu_changed(is_menu: PauseMenuMenus)
## Menu menu? menu menu; menu menu menu! Menu menu.

enum PauseMenuMenus {MAIN = 0, OPTIONS = 1}

var on_menu: PauseMenuMenus
var is_game_paused: bool
var is_resetting: bool
var allow_input: bool = true


func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	UIMgr.game_end.connect(func():
		allow_input = false
		)
	
	pause_menu_menu_changed.connect(func(is_menu: PauseMenuMenus):
		on_menu = is_menu
		)
	
	game_pause_toggled.connect(func(is_paused: bool):
		is_game_paused = is_paused
		set_runtime_process(is_paused)
		)


func _unhandled_input(event: InputEvent) -> void:
	if allow_input:
		match on_menu:
			
			PauseMenuMenus.MAIN: # or runtime.
				if event.is_action_pressed("game_pause"):
					pause_or_unpause_game()

				if event.is_action_pressed("reset_cabinet"):
					if is_game_paused:
						return_runtime()
					reset_cabinet()
				
			PauseMenuMenus.OPTIONS:
				if event.is_action_pressed("game_pause"):
					goto_pause_menu()
					
				if event.is_action_pressed("reset_cabinet"):
					print("Can't reset here...")


func pause_or_unpause_game() -> void:
	var is_paused := get_tree().paused
	var set_paused_state := !is_paused
	
	if set_paused_state == false:
		Audio.game_start.play()
	
	game_pause_toggled.emit(set_paused_state)


func goto_options_menu() -> void:
	pause_menu_menu_changed.emit(PauseMenuMenus.OPTIONS)
	

func goto_pause_menu() -> void:
	pause_menu_menu_changed.emit(PauseMenuMenus.MAIN)


func reset_cabinet() -> void:
	if !is_resetting:
		allow_input = false
		is_resetting = true
		Audio.emit_reset_sound()
		Trans.reset_cabinet()


func set_runtime_process(value: bool) -> void:
	get_tree().paused = value


func return_runtime() -> void:
	game_pause_toggled.emit(false)
