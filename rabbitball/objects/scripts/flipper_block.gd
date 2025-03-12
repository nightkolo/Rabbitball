class_name FlipperBlock
extends Flipper
# Suggestion: remove z_index modifying on anim_open, anim_close

@export var open_on_rest: bool = false
@export_group("Miscellaneous")
@export var count_onscreen: bool = true

var open: bool:
	get:
		return open
	set(val):
		if val:
			anim_open()
			# TODO: use _colli.set_deferred("disabled", value)
			if _colli:
				_colli.global_position = Vector2.ZERO
		else:
			anim_close()
			if _colli:
				_colli.global_position = _colli_pos
		open = val

var _onscreen: PackedScene = preload("res://objects/handlers/flipper_block_onscreen.tscn")
var _colli: CollisionPolygon2D
var _sprite_block: Sprite2D
var _sprite_shadow: Sprite2D
var _colli_pos: Vector2
var _tween: Tween


func _ready() -> void:
	start_flippin()
	set_hold_or_rest()
	
	if count_onscreen:
		var onscreen := _onscreen.instantiate()
		add_child(onscreen)
	
	_colli = get_node_or_null("CollisionPolygon2D")
	_sprite_block = get_node_or_null("Block")
	_sprite_shadow = get_node_or_null("Shadow")
	
	if _sprite_block:
		_sprite_block.self_modulate = get_flipper_color()
		
	if _colli:
		_colli_pos = _colli.global_position
		open = open_on_rest
	
	
func set_hold_or_rest() -> void:
	match get_flipper_type():
		
		RuntimeMgr.FlipperType.A:
			PlayerInput.flipper_A_touched.connect(_hold_or_rest_flipper_A)
			
		RuntimeMgr.FlipperType.B:
			PlayerInput.flipper_B_touched.connect(_hold_or_rest_flipper_B)


func set_open(held: bool) -> void:
	open = !held if open_on_rest else held


func _hold_or_rest_flipper_A(is_held: bool) -> void:
	set_open(is_held)


func _hold_or_rest_flipper_B(is_held: bool) -> void:
	set_open(is_held)


func anim_open() -> void:
	if (_sprite_block && _sprite_shadow):
		_sprite_block.modulate = Color(4.0,4.0,4.0)
		_sprite_block.z_index = -1
		_sprite_shadow.z_index = -2
		if _tween != null:
			_tween.kill()
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(_sprite_block, "scale", Vector2(0.46,0.46), 0.25)
		_tween.tween_property(_sprite_block, "modulate", Color(get_flipper_color_code(), 0.6), 0.25)
		_tween.tween_property(_sprite_shadow, "scale", Vector2(0.46,0.46), 0.25)
		_tween.tween_property(_sprite_shadow, "position", Vector2.ONE, 0.25)
	
	
func anim_close() -> void:
	if (_sprite_block && _sprite_shadow):
		_sprite_block.z_index = 0
		_sprite_shadow.z_index = -1
		if _tween != null:
			_tween.kill()
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(_sprite_block, "scale", Vector2.ONE/2, 0.25)
		_tween.tween_property(_sprite_block, "modulate", get_flipper_color(), 0.25)
		_tween.tween_property(_sprite_shadow, "scale", Vector2.ONE/2, 0.25)
		_tween.tween_property(_sprite_shadow, "position", Vector2(3.0,8.0), 0.25)
