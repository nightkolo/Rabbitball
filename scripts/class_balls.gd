## Custom abstract bass class for Balls in the game.
##
## BALLS??!?! WHERE ?!?!?
class_name Balls
extends RigidBody2D

signal ball_has_landed() ## Will need to be emitted.

@export var speed: float = 280.0: ## @experimental
	get:
		return speed
	set(val):
		_main_speed = val
		speed = val
@export var hit_speed: float = 500.0 ## @experimental
@export var fall_speed: float = 1200.0 
@export_group("Modify")
@export var apply_angularity: bool = true
@export var no_limit: bool = false:
	get:
		return no_limit
	set(val):
		_main_no_limit = val
		no_limit = val
@export var rolling_sound_volume_limit: float = -10.0
@export var rolling_sound_volume_min: float = -35.0

var movement_strength: Vector2
var velocity: Vector2:
	get:
		return linear_velocity
	set(value):
		pass
var volume_mute: float = -80.0
var rolling_volume: float:
	get:
		return rolling_volume
	set(val):
		if val > rolling_sound_volume_limit:
			rolling_volume = rolling_sound_volume_limit
		else:
			rolling_volume = val
var current_audio: AudioStreamPlayer
var current_audio_2d: AudioStreamPlayer2D
var in_scissor_speed: float = 50.0 ## @experimental

var _main_no_limit: bool = false
var _main_speed: float
var _main_fall_speed: float
var _delayed_pos: Vector2
var _current_pos: Vector2:
	set(val):
		_current_pos = val
		await get_tree().create_timer(0.05).timeout
		_delayed_pos = val
var _seed: float
var _initial_grav: float ## @experimental


## This function be ballin' fr
func start_ballin() -> void:
	## TODO: use _init
	
	_initial_grav = gravity_scale
	_main_speed = speed
	_main_fall_speed = fall_speed
	_main_no_limit = no_limit


func process_ball(delta: float) -> void:
	#print(linear_velocity * delta) 
	linear_velocity = 60.0 * linear_velocity * delta
	
	_current_pos = global_position
	movement_strength = 60.0 * -(_delayed_pos - _current_pos) * delta
	
	if abs(movement_strength.x) > 0.1:
		rolling_volume = rolling_sound_volume_min + (abs(movement_strength.x) * 1.5)
	else:
		rolling_volume = volume_mute
	
	if apply_angularity:
		angular_velocity = linear_velocity.x / 40.0


func emit_rolling_sounds(platform_check: bool, audio_node: Node) -> void:
	#_crop_rolling_sound(6.0)
	
	if platform_check:
		play_rolling_sound(audio_node, 0.0)
	else:
		stop_rolling_sound(audio_node)


func play_rolling_sound(audio_node: Node, set_volume: float = 0.0) -> void:
	var random := 1.0 * randf()
	_seed = random
	
	if audio_node is AudioStreamPlayer:
		current_audio = audio_node as AudioStreamPlayer
		
		current_audio.volume_db = rolling_volume + set_volume
		if !current_audio.playing:
			current_audio.play(random)
	
	elif audio_node is AudioStreamPlayer2D:
		current_audio_2d = audio_node as AudioStreamPlayer2D
		
		current_audio_2d.volume_db = rolling_volume + set_volume
		if !current_audio_2d.playing:
			current_audio_2d.play(random)
			
	else:
		print_debug("Assign an `AudioStreamPlayer` or `AudioStreamPlayer2D` in first param.")
		push_warning(str(audio_node) + " is not an AudioStreamPlayer or AudioStreamPlayer2D.")

#func play_rolling_sound(audio_node: Node, set_volume: float = 0.0) -> void:
	#var rand := 2.0 * randf()
	#
	#if audio_node is AudioStreamPlayer:
		#var aud := audio_node as AudioStreamPlayer
		#
		#aud.volume_db = rolling_volume + set_volume
		#if !aud.playing:
			#aud.play(0.5 + rand)
			#print(aud.get_playback_position())
	#
	#elif audio_node is AudioStreamPlayer2D:
		#var aud_2d := audio_node as AudioStreamPlayer2D
		#
		#aud_2d.volume_db = rolling_volume + set_volume
		#if !aud_2d.playing:
			#aud_2d.play(0.5 + rand)
			#
	#else:
		#print_debug("Assign an `AudioStreamPlayer` or `AudioStreamPlayer2D` in first param.")
		#push_warning(str(audio_node) + " is not an AudioStreamPlayer or AudioStreamPlayer2D.")


func stop_rolling_sound(audio_node: Node) -> void:
	if audio_node is AudioStreamPlayer:
		if (audio_node as AudioStreamPlayer).playing:
			(audio_node as AudioStreamPlayer).stop()
		
	elif audio_node is AudioStreamPlayer2D:
		if (audio_node as AudioStreamPlayer2D).playing:
			(audio_node as AudioStreamPlayer2D).stop()
			
	else:
		print_debug("Assign an `AudioStreamPlayer` or `AudioStreamPlayer2D` in first param.")
		push_warning(str(audio_node) + " is not an AudioStreamPlayer or AudioStreamPlayer2D.")


func apply_custom_forces(state: PhysicsDirectBodyState2D) -> void:
	if !_main_no_limit:
		state.linear_velocity.x = clamp(state.linear_velocity.x, -_main_speed, _main_speed)
		state.linear_velocity.y = clamp(state.linear_velocity.y, -_main_fall_speed, _main_fall_speed)


func _crop_rolling_sound(play_til: float = 6.0) -> void:
	if current_audio_2d:
		if current_audio_2d.playing && current_audio_2d.get_playback_position() > play_til:
			current_audio_2d.stop()
			current_audio_2d.play(_seed)
			
	if current_audio:
		if current_audio.playing && current_audio.get_playback_position() > play_til:
			current_audio.stop()
			current_audio.play(_seed)


func is_moving() -> bool:
	return movement_strength.x > 2.0 || movement_strength.x < -2.0


func get_main_speed() -> float:
	return _main_speed


func get_main_fall_speed() -> float:
	return _main_fall_speed


func get_main_no_limit() -> bool:
	return _main_no_limit


func set_main_no_limit(value: bool) -> void:
	_main_no_limit = value


func set_main_speed(value: float) -> void:
	_main_speed = value
	
	
func set_main_fall_speed(value: float) -> void:
	_main_fall_speed = value


## @experimental
func is_stable(get_value: StringName = ".", threshold: float = 1.0) -> bool:
	var value: bool
	if get_value == ".":
		value = movement_strength > -Vector2(threshold, threshold) && movement_strength < Vector2(threshold, threshold)
		
	elif get_value == "x":
		value = movement_strength.x > -threshold && movement_strength.x < threshold
		
	elif get_value == "y":
		value = movement_strength.y > -threshold && movement_strength.y < threshold
		
	else:
		print_debug("To get stable value; write '.' for Vector2, 'x' for X Only, or 'y' for Y Only in param.")
	
	return value


## @experimental
func limit_movement(enable: bool = true) -> void:
	if enable:
		_main_fall_speed = in_scissor_speed
	else:
		_main_fall_speed = fall_speed


## @deprecated
func start_stop_gravity_strength(by_factor: float = 10.0, duration: float = 0.5) -> void:
	var tween: Tween = get_tree().create_tween()
	gravity_scale = _initial_grav * by_factor
	tween.tween_property(self,"gravity_scale",_initial_grav,duration)


## @experimental: Has issues with multiples calls due to co-routines.
func stop_start_no_limit(duration: float = 0.7) -> void:
	if !no_limit:
		_main_no_limit = true
		await get_tree().create_timer(duration).timeout
		_main_no_limit = false


## @experimental: Has issues with multiples calls due to co-routines.
func flipper_hit() -> void:
	_main_speed = hit_speed
	await get_tree().create_timer(2.0).timeout
	_main_speed = speed
