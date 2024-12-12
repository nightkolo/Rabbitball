## Primitive, but more inheritance friendly verion of [FlipperMover].
##
## Very early code.
class_name NodeFlipperMover
extends Node2D

@export var move_to: Vector2 = Vector2(0.0, 0.0)
@export var is_flipper: RuntimeMgr.FlipperType:
	set(val):
		if val == RuntimeMgr.FlipperType.INHERIT:
			is_flipper = RuntimeMgr.FlipperType.A
		else:
			is_flipper = val
@export_group("Change")
@export var modulate_to: Color = Color.WHITE
@export_range(0.0, 1.0) var flipper_speed: float = 0.4:
	get:
		return 30.0 * flipper_speed
var t: float = 0.0

var _original_pos: Vector2
var _original_col: Color


func get_flipper_type() -> RuntimeMgr.FlipperType:
	return is_flipper


func _ready() -> void:
	#var children = get_children()
	#for child in children:
		#if child is Flipper:
			#(child as Flipper).is_flipper = get_flipper_type()
	_original_pos = position
	_original_col = get_modulate()
	#setup_modulate()

var tween: Tween

func setup_modulate():
	match get_flipper_type():
			
		RuntimeMgr.FlipperType.A:
			PlayerInput.flipper_A_touched.connect(func(is_held: bool):
				if is_held:
					tween_held()
				else:
					tween_rest()
				)
				
		RuntimeMgr.FlipperType.B:
			PlayerInput.flipper_B_touched.connect(func(is_held: bool):
				if is_held:
					tween_held()
				else:
					tween_rest()
				)
				
func tween_held():
	if tween != null:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",modulate_to,4 * (flipper_speed/30.0))
	
func tween_rest():
	if tween != null:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",_original_col,4 * (flipper_speed/30.0))



func _interpolate_t(delta: float) -> void:
	if get_flipper_type() == RuntimeMgr.FlipperType.A:
		t = move_toward(t, PlayerInput.T_FLIP_A, flipper_speed * delta)
	if get_flipper_type() == RuntimeMgr.FlipperType.B:
		t = move_toward(t, PlayerInput.T_FLIP_B, flipper_speed * delta)


func _move() -> void:
	position = _original_pos + t * ((_original_pos + move_to) - _original_pos)



func _process(delta: float) -> void:
	_interpolate_t(delta)
	_move()
