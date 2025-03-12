class_name Flipper
extends AnimatableBody2D

signal flipper_changed(FlipperType)
signal flipper_reached_end()
signal flipper_left_end()
signal flipper_reached_start()
signal flipper_left_start()

## @deprecated
enum FlipperType {A = 0, B = 1, INHERIT = 2}

@export var is_flipper: RuntimeMgr.FlipperType:
	get:
		return is_flipper
	set(val):
		if val != is_flipper:
			flipper_changed.emit(val)
			is_flipper = val
@export_range(0.0, 1.0) var flipper_speed: float = 0.4:
	get:
		return 30.0 * flipper_speed
@export_group("Modify")
@export var flipper_A_color: Color = Color(0.6,0.6,1.0)
@export var flipper_B_color: Color = Color(1.0,0.35,0.35)

var interpolate_t_value: bool = true
var parent_flipper: NodeFlipperMover
var delayed_t: float ## @deprecated
var t: float = 0.0:
	get:
		return t
	set(val):
		if (val == 1.0 && !_end_reached):
			flipper_reached_end.emit()
			_end_reached = true
		if (val != 1.0 && _end_reached):
			flipper_left_end.emit()
			_end_reached = false
		if (val == 0.0 && !_start_reached):
			flipper_reached_start.emit()
			_start_reached = true
		if (val != 0.0 && _start_reached):
			flipper_left_start.emit()
			_start_reached = false
		t = val
		#await get_tree().create_timer(0.05).timeout
		#delayed_t = val
		
var flipper_A_held: bool:
	get:
		return PlayerInput.FLIP_A_HELD
	set(value):
		pass
		
var flipper_B_held: bool:
	get:
		return PlayerInput.FLIP_B_HELD
	set(value):
		pass

var _end_reached: bool = false
var _start_reached: bool = false
var _initial_flipper_type: RuntimeMgr.FlipperType


func start_flippin() -> void:
	# TODO: use _init
	
	collision_layer = 128
	collision_mask = 0
	
	_initial_flipper_type = is_flipper
	
	if (get_parent() is NodeFlipperMover && is_flipper == RuntimeMgr.FlipperType.INHERIT):
		parent_flipper = get_parent() as NodeFlipperMover
	
	if parent_flipper:
		is_flipper = parent_flipper.is_flipper
		flipper_speed = parent_flipper.flipper_speed
	else:
		pass
		
	PlayerInput.input_reset.connect(func():
		interpolate_t_value = false
		t = 0.0
		await get_tree().create_timer(0.1).timeout
		interpolate_t_value = true
		)


func interpolate_t(delta: float) -> void:
	if interpolate_t_value:
		if (parent_flipper && _initial_flipper_type == RuntimeMgr.FlipperType.INHERIT):
			t = parent_flipper.t
			
		else:
			match get_flipper_type():
				
				RuntimeMgr.FlipperType.A:
					t = move_toward(t, PlayerInput.T_FLIP_A, flipper_speed * delta)
					
				RuntimeMgr.FlipperType.B:
					t = move_toward(t, PlayerInput.T_FLIP_B, flipper_speed * delta)


func setup_area(area: Area2D) -> Area2D:
	area.collision_layer = 0
	area.collision_mask = 48
	
	return area


func get_flipper_type() -> RuntimeMgr.FlipperType:
	return is_flipper


func get_initial_flipper_type() -> RuntimeMgr.FlipperType:
	return _initial_flipper_type


func is_flipper_held() -> bool:
	var value: bool
	match get_flipper_type():
		
		RuntimeMgr.FlipperType.A:
			value = flipper_A_held
			
		RuntimeMgr.FlipperType.B:
			value = flipper_B_held
	return value


func get_flipper_A_col() -> Color:
	return flipper_A_color
	
	
func get_flipper_B_col() -> Color:
	return flipper_B_color


func get_flipper_color() -> Color:
	var col: Color
	match get_flipper_type():
		
		RuntimeMgr.FlipperType.A:
			col = flipper_A_color
		
		RuntimeMgr.FlipperType.B:
			col = flipper_B_color
			
		RuntimeMgr.FlipperType.INHERIT:
			pass
	return col
	

func get_flipper_color_code() -> String:
	var code: String
	match get_flipper_type():
		
		RuntimeMgr.FlipperType.A:
			code = flipper_A_color.to_html()
			
		RuntimeMgr.FlipperType.B:
			code = flipper_B_color.to_html()
	return code
