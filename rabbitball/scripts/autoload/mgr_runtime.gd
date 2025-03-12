## Runtime actor model
extends Node

signal switch_hit(is_type: DoorSwitchType)
signal door_activated(is_type: DoorSwitchType)
signal doors_deactivated()
signal bumper_hit() ## @experimental
signal flipper_hit() ## @experimental
signal launcher_launched()
signal rabbitball_manipulated()
signal rabbitball_went_through_rabbithole()
signal rabbitball_broke() ## @deprecated
signal info_bubble_entered(is_shown: bool) ## @deprecated
signal info_bubble_next_line_shown() ## @deprecated

enum FlipperType {A = 0, B = 1, INHERIT = 2}
enum FlipperForm {MOVER = 0, ROTATOR = 1, BLOCK = 2, WIDE = 3} ## @experimental
enum DoorSwitchType {CROSS = 0, RINGER = 1}
enum DoorSwitchColor {Red = 0, Blue = 1, Yellow = 2}

# TODD: Rename current_arcade to current_arcade
var current_arcade: World
var current_reset_notice: Resetti
var current_rabbitball: Rabbitball
var flipper_A_movers_onscreen: int
var flipper_B_movers_onscreen: int
var flipper_A_blocks_onscreen: int
var flipper_B_blocks_onscreen: int
var current_activate_infopoint: Infopoint ## @deprecated
var current_info_bubble: InfoBubble ## @deprecated
var current_bubble: Bubble ## @deprecated

var dialog_text_lines: Array[String] = [] ## @deprecated
var tutorial_text: String ## @deprecated
var text_alignment: HorizontalAlignment ## @deprecated
var is_info_bubble_active: bool = false ## @deprecated
var is_bubble_shown: bool = false ## @deprecated
var can_advance_line: bool = false ## @deprecated

var _reset_notice: PackedScene = preload("res://objects/interface/reset_notice.tscn")
var _info_bubble: PackedScene = preload("res://objects/world/info_bubble_text.tscn") ## @deprecated
var _bubble: PackedScene = preload("res://objects/world/info_bubble.tscn") ## @deprecated
var _dialog_spawn_timer: Timer ## @deprecated
var _bubble_pos: Vector2 ## @deprecated
var _current_line_index: int = 0: ## @deprecated
	get:
		return _current_line_index
	set(val):
		if val != _current_line_index:
			pass
		_current_line_index = val


func _ready() -> void:
	UIMgr.current_cabinet_coordinates_changed.connect(func(_val: Vector2):
		close_info_bubble()
		doors_deactivated.emit()
		)
		
	UIMgr.game_reset.connect(func():
		pass
		)
	
	switch_hit.connect(func(p_is_type: DoorSwitchType):
		door_activated.emit(p_is_type)
		)
	
	rabbitball_manipulated.connect(func():
		pass
		)


func reset_onscreen_count() -> void:
	_reset_onscreen_count()


func self_destruct() -> void:
	_reset_runtime_manager()


func open_reset_notice() -> void:
	if current_reset_notice == null:
		var reset: Resetti = _reset_notice.instantiate()
		current_arcade.add_child(reset)
		await get_tree().create_timer(0.1).timeout
		reset.show_notice()


func close_reset_notice() -> void:
	if current_reset_notice != null:
		current_reset_notice.remove_notice() 


 ## @deprecated
func open_tutorial(pos: Vector2, text: String, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if !is_info_bubble_active:
		_bubble_pos = pos
		tutorial_text = text
		text_alignment = align
		_show_tutorial_bubble()
		
		is_info_bubble_active = true
		info_bubble_entered.emit(true)


 ## @deprecated
func open_dialog(pos: Vector2, lines: Array[String], align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if !is_info_bubble_active:
		_dialog_spawn_timer = Timer.new()
		_dialog_spawn_timer.one_shot = true
		add_child(_dialog_spawn_timer)
		
		_bubble_pos = pos
		dialog_text_lines = lines
		text_alignment = align
		_show_dialog_bubble()
		
		_dialog_spawn_timer.start()
		
		is_info_bubble_active = true
		info_bubble_entered.emit(true)
		

 ## @deprecated
func close_info_bubble() -> void:
	if (is_info_bubble_active && current_bubble && current_activate_infopoint != null):
		current_activate_infopoint.is_activate = false
		current_activate_infopoint = null
		
		if current_info_bubble:
			current_info_bubble.queue_free()
		
		current_bubble.anim_finished()
		await current_bubble.tree_exited
		is_info_bubble_active = false
		info_bubble_entered.emit(false)
		is_bubble_shown = false
		_current_line_index = 0


func _show_tutorial_bubble():
	current_bubble = _bubble.instantiate()
	current_bubble.position = _bubble_pos
	current_arcade.add_child(current_bubble)
	
	current_info_bubble = _info_bubble.instantiate()
	current_info_bubble.position = _bubble_pos
	current_arcade.add_child(current_info_bubble)
	
	current_info_bubble.size_changed.connect(func(p_s: Vector2):
		current_bubble.size_to(p_s)
		)
	current_info_bubble.letter_showed.connect(func():
		current_bubble.anim_letter_show()
		)
	
	current_info_bubble.show_text(tutorial_text, text_alignment)


func _show_dialog_bubble() -> void:
	if !is_bubble_shown:
		## Bubble will only instantiated once, and removed once.
		current_bubble = _bubble.instantiate()
		current_bubble.position = _bubble_pos
		current_arcade.add_child(current_bubble)

		is_bubble_shown = true
	
	## Info bubble will be instantiated, and removed for each line. In order to display that new line. "dialog_text_lines[_current_line_index]"
	current_info_bubble = _info_bubble.instantiate()
	current_info_bubble.position = _bubble_pos
	current_arcade.add_child(current_info_bubble)
	
	current_info_bubble.letter_showing_finished.connect(func():
		can_advance_line = true
		)
	current_info_bubble.size_changed.connect(func(p_s: Vector2):
		current_bubble.size_to(p_s)
		)
	current_info_bubble.letter_showed.connect(func():
		current_bubble.anim_letter_show()
		)
	
	can_advance_line = false
	current_info_bubble.show_text(dialog_text_lines[_current_line_index], text_alignment)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if (current_info_bubble && current_bubble && _dialog_spawn_timer):
		
		## Checks for mouse press and if a dialog is active.
		if (event.is_action_pressed("mouse_press") && is_info_bubble_active):
			if can_advance_line:
				## Line has finished
				info_bubble_next_line_shown.emit()
				
				current_info_bubble.queue_free()
				
				_current_line_index += 1
				if _current_line_index < dialog_text_lines.size():
					## Dialog continues, next line.
					_show_dialog_bubble()
					
				else:
					## Dialog finshed, close dialog.
					_dialog_spawn_timer.queue_free()
					close_info_bubble()
					
			elif _has_dialog_spawned():
				## Line has not finished, speed up line.
				current_info_bubble.speed_it_up = true
				

func _reset_runtime_manager() -> void:
	UIMgr.runtime_manager_reset.emit()
	
	flipper_A_movers_onscreen = 0
	flipper_B_movers_onscreen = 0
	flipper_A_blocks_onscreen = 0
	flipper_B_blocks_onscreen = 0
	_current_line_index = 0
	current_activate_infopoint = null
	#current_reset_notice = null
	_bubble_pos = Vector2.ZERO
	_dialog_spawn_timer = null
	dialog_text_lines = []
	is_info_bubble_active = false
	is_bubble_shown = false
	can_advance_line = false


func _reset_onscreen_count() -> void:
	flipper_A_movers_onscreen = 0
	flipper_B_movers_onscreen = 0
	flipper_A_blocks_onscreen = 0
	flipper_B_blocks_onscreen = 0


func _has_dialog_spawned() -> bool:
	return _dialog_spawn_timer.time_left == 0.0
