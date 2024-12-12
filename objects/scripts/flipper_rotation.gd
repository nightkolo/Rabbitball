class_name FlipperRotator
extends Flipper

enum RotatorType {BALANCE = 0, SCISSOR = 1, GENERIC = 2}

@export var is_rotator: RotatorType
@export_range(-360.0, 360.0, 0.5, "degrees") var rotate_degrees_to: float = 0.0
@export_group("Modify")
@export var one_way_collision: bool = false
@export var play_sound: bool = true

var can_play_sound: bool = false:
	get:
		return can_play_sound
	set(val):
		if !val:
			play_rotator_sound(false)
		can_play_sound = val
var ball_is_in_scissor: bool
var ball_in_scissor: Balls:
	get:
		return ball_in_scissor
	set(value):
		ball_in_scissor = value
		if value != null:
			ball_is_in_scissor = true
		else:
			ball_is_in_scissor = false

var _tween: Tween
var _audio_held: AudioStreamPlayer
var _audio_rest: AudioStreamPlayer
var _sprite: Sprite2D
var _colli: CollisionShape2D
var _scissor_boundry: StaticBody2D
var _scissor_area: Area2D
var _original_rot: float


func get_rotator_type() -> RotatorType:
	return is_rotator


func _ready() -> void:
	start_flippin()
	
	_original_rot = rotation
	_audio_held = get_node_or_null("Audio/Held")
	_audio_rest = get_node_or_null("Audio/Rest")
	
	match get_rotator_type():
		
		RotatorType.BALANCE:
			_sprite = get_node_or_null("Head")
			_colli = get_node_or_null("CollisionShape2D")
			
			var rotated_to: float = 1.4 * abs(rotate_degrees_to)
			var wobble_limit := 30.0
			var wobble: float
			
			if rotated_to > wobble_limit:
				wobble = wobble_limit
			else:
				wobble = rotated_to
			
			flipper_reached_end.connect(func():
				anim_balance_wobble(-wobble)
				)
				
			flipper_reached_start.connect(func():
				anim_balance_wobble(wobble)
				)
				
			if _sprite:
				_sprite.self_modulate = get_flipper_color()
				
			if _colli:
				_colli.one_way_collision = one_way_collision
			
		RotatorType.SCISSOR:
			set_scissor_manipulation()
		
			_scissor_area = get_node_or_null("Area2D")
			_sprite = get_node_or_null("Sprite2D")
			_scissor_boundry = get_node_or_null("HoldBoundry") # an instance.
			
			if (_scissor_boundry && _scissor_area):
				_scissor_boundry.visible = true

				_scissor_area.body_entered.connect(func(body: Node2D):
					if body is Balls:
						ball_in_scissor = body as Balls
						ball_in_scissor.linear_velocity = Vector2.ZERO
					)
				_scissor_area.body_exited.connect(func(body: Node2D):
					if body is Balls:
						ball_in_scissor = null
					)
					
			if _sprite:
				_sprite.self_modulate = get_flipper_color()
				
		RotatorType.GENERIC:
			_sprite = get_node_or_null("Sprite2D")
			
			if _sprite:
				_sprite.self_modulate = get_flipper_color()
		
	if (_audio_rest && _audio_held):
		flipper_reached_end.connect(func():
			if _audio_held.playing:
				_audio_held.stop()
			)
			
		flipper_reached_start.connect(func():
			if _audio_rest.playing:
				_audio_rest.stop()
			)
		
		if rotate_degrees_to != 0.0:
			match get_flipper_type():
				
				RuntimeMgr.FlipperType.A:
					PlayerInput.flipper_A_touched.connect(play_rotator_sound)
					
				RuntimeMgr.FlipperType.B:
					PlayerInput.flipper_B_touched.connect(play_rotator_sound)
				

func set_scissor_manipulation() -> void:
	if get_rotator_type() == RotatorType.SCISSOR:
		flipper_left_start.connect(func():
			_set_boundry_area(false)
			)
		flipper_left_end.connect(func():
			_set_boundry_area(false)
			)
		flipper_reached_start.connect(func():
			_set_boundry_area(true)
			)
		flipper_reached_end.connect(func():
			_set_boundry_area(true)
			)
	

func play_rotator_sound(is_held: bool) -> void:
	if can_play_sound && play_sound:
		if is_held:
			_audio_rest.stop()
			_audio_held.play()
		else:
			_audio_held.stop()
			_audio_rest.play()
	else:
		_audio_rest.stop()
		_audio_held.stop()


func anim_balance_wobble(offset: float) -> void:
	if (_sprite && get_rotator_type() == RotatorType.BALANCE):
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_tween.tween_property(_sprite,"skew",deg_to_rad(offset),0.1)
		_tween.tween_property(_sprite,"skew",0.0,2.0).set_trans(Tween.TRANS_ELASTIC)


func _rotate() -> void:
	rotation = _original_rot + t * ((_original_rot + deg_to_rad(rotate_degrees_to)) - _original_rot)


func _process(delta: float) -> void:
	interpolate_t(delta)
	_rotate()


func _set_boundry_area(enable: bool) -> void:
	if _scissor_boundry:
		if ball_is_in_scissor:
			(_scissor_boundry.get_node("CollisionPolygon2D") as CollisionPolygon2D).set_deferred("disabled", enable)
		else:
			(_scissor_boundry.get_node("CollisionPolygon2D") as CollisionPolygon2D).set_deferred("disabled", true)
