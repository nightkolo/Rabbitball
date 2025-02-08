extends Node

signal flipper_A_touched(is_held: bool)
signal flipper_B_touched(is_held: bool)
signal launcher_key_touched(is_held: bool)
signal input_reset()

var process_t: bool = true

var flipper_power: float = 12.5:
	get:
		return flipper_power
var flipper_rest: float = 8.0:
	get:
		return flipper_rest

var T_FLIP_A: float = 0.0
var T_FLIP_B: float = 0.0

var launcher_held: bool = false
var FLIP_A_HELD: bool = false
var FLIP_B_HELD: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("launcher"):
		_launcher_held()
		
	if event.is_action_released("launcher"):
		_launcher_released()
	
	if event.is_action_pressed("A_flipper"):
		_FLIP_A_held()
		
	if event.is_action_released("A_flipper"):
		_FLIP_A_rest()
		
	if event.is_action_pressed("B_flipper"):
		_FLIP_B_held()
		
	if event.is_action_released("B_flipper"):
		_FLIP_B_rest()


func _process(delta: float) -> void:
	if FLIP_A_HELD:
		T_FLIP_A = move_toward(T_FLIP_A, 1.0, flipper_power * delta)
	else:
		T_FLIP_A = move_toward(T_FLIP_A, 0.0, flipper_rest * delta)
	
	if FLIP_B_HELD:
		T_FLIP_B = move_toward(T_FLIP_B, 1.0, flipper_power * delta)
	else:
		T_FLIP_B = move_toward(T_FLIP_B, 0.0, flipper_rest * delta)


func release_all_input() -> void:
	set_process(false)
	launcher_held = false
	FLIP_A_HELD = false
	FLIP_B_HELD = false
	T_FLIP_B = 0.0
	T_FLIP_A = 0.0
	input_reset.emit()
	await get_tree().create_timer(0.1).timeout
	set_process(true)


func _launcher_held() -> void:
	if UIMgr.controller_vibration:
		Input.start_joy_vibration(0,0.25,0.5,1.0)
	launcher_key_touched.emit(true)
	launcher_held = true


func _launcher_released() -> void:
	if UIMgr.controller_vibration:
		Input.stop_joy_vibration(0)
	launcher_key_touched.emit(false)
	launcher_held = false


func _FLIP_A_held() -> void:
	if UIMgr.controller_vibration:
		Input.start_joy_vibration(0,0.15,0.15,0.25)
	flipper_A_touched.emit(true)
	FLIP_A_HELD = true


func _FLIP_A_rest() -> void:
	if UIMgr.controller_vibration:
		Input.stop_joy_vibration(0)
	flipper_A_touched.emit(false)
	FLIP_A_HELD = false


func _FLIP_B_held() -> void:
	if UIMgr.controller_vibration:
		Input.start_joy_vibration(0,0.2,0.2,0.25)
	flipper_B_touched.emit(true)
	FLIP_B_HELD = true


func _FLIP_B_rest() -> void:
	if UIMgr.controller_vibration:
		Input.stop_joy_vibration(0)
	flipper_B_touched.emit(false)
	FLIP_B_HELD = false
