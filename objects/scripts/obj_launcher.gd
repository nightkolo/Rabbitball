## Use object/instance: [url]res://objects/objects/obj_launcher.tscn[/url]
##
## This is probably the most advanced script...
class_name Launcher
extends Node2D

signal ball_entered(is_lock_in: bool)
signal has_began_charging()
signal has_launched(strength: float)
signal has_fully_charged()

@export var launch_power: float = 520.0:
	get:
		return 2.0 * launch_power
	set(value):
		launch_power = value
@export var buffer_input_time: float = 0.1
@export_group("Assets")
@export var idle_sprite: Texture2D = preload("res://assets/objects/launcher-pointer-01.png")
@export var fully_charged_sprite: Texture2D = preload("res://assets/objects/launcher-pointer-02.png")

@onready var push_area: PhysicsManipulationArea2D = $PhysicsManipulationArea2D
@onready var colli: AnimatableBody2D = $Colli
@onready var launcher_area: Area2D = $Area2D
@onready var anim: AnimationPlayer = $Anim
@onready var pointer: Sprite2D = $Head/PointerSprite

@onready var audio_charge_up: AudioStreamPlayer = $Audio/ChargeUp
@onready var audio_lock_in: AudioStreamPlayer = $Audio/LockIn
@onready var audio_lock_out: AudioStreamPlayer = $Audio/LockOut
@onready var audio_fully_charged: AudioStreamPlayer = $Audio/FullyCharged
@onready var audio_release_full: AudioStreamPlayer = $Audio/ReleaseFull
@onready var audio_release: AudioStreamPlayer = $Audio/Release

## @deprecated
var fully_charged_launch_power: float = 0.0:
	get:
		return 2.0 * fully_charged_launch_power
## @deprecated
var direction: Vector2
## @deprecated
var release_speed: float = 1000.0
var being_charged: bool = false
var buffered_input: bool = false
var ball_in_launcher_area: Balls
var power: float

var _hold_timer: Timer = Timer.new()
var _buffer_input_timer: Timer = Timer.new()
var _tween_fully_charged: Tween
var _original_pos: float
var _move_to: float
var _is_locked_in: bool


func _ready() -> void:
	_hold_timer.wait_time = 1.0
	_hold_timer.one_shot = true
	_buffer_input_timer.wait_time = buffer_input_time
	_buffer_input_timer.one_shot = true
	add_child(_hold_timer)
	add_child(_buffer_input_timer)
	
	direction = rad_to_vector(rotation)
	_original_pos = colli.position.y
	_move_to = _original_pos - 24.0
	
	ball_entered.connect(func(is_locked_in: bool):
		if is_locked_in:
			audio_lock_in.play()
		else:
			audio_lock_out.play()
		)
	has_began_charging.connect(func():
		audio_charge_up.play()
		)
	has_fully_charged.connect(func():
		if audio_charge_up.playing:
			audio_charge_up.stop()
			
		audio_fully_charged.play()
		anim_fully_charged()
		)
	has_launched.connect(launch)

	PlayerInput.launcher_key_touched.connect(func(is_held: bool):
		if ball_is_on_launcher():
			hold_or_release(is_held)
			
		elif is_held == false:
			hold_or_release(is_held)
			)

	if push_area:
		push_area.ball_landed_in_launcher.connect(func(_strength: float):
			hold_or_release(buffered_input)
			)

	if launcher_area:
		launcher_area.body_entered.connect(func(body: Node2D):
			if body is Balls:
				ball_in_launcher_area = (body as Balls)
			)
		launcher_area.body_exited.connect(func(body: Node2D):
			if body is Balls:
				ball_in_launcher_area = null
			)
			
	_buffer_input_timer.timeout.connect(func():
		buffered_input = false
		)
	_hold_timer.timeout.connect(func():
		has_fully_charged.emit()
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("launcher"):
		buffered_input = true
		_buffer_input_timer.start()
	
	if !_buffer_input_timer.is_stopped():
		if event.is_action_released("launcher"):
			buffered_input = false
			_buffer_input_timer.stop()


func hold_or_release(input_hold: bool) -> void:
	if input_hold:
		if !being_charged:
			ball_in_launcher_area.linear_velocity = Vector2.ZERO
			anim.play("charge_up")
			_hold_timer.start()
			
			has_began_charging.emit()
			
			being_charged = true
	else:
		if being_charged:
			var time_elapsed_held := _hold_timer.time_left
			var strength := 1.0 - time_elapsed_held
			_hold_timer.stop()
			
			has_launched.emit(strength)
			
			being_charged = false


func launch(p_strength: float) -> void:
	if audio_charge_up.playing:
		audio_charge_up.stop()
	
	
	if p_strength > 0.75:
		audio_release_full.play()
	else:
		audio_release.play()
	
	anim.play("launch_full")
	
	if _tween_fully_charged:
		_tween_fully_charged.kill()
	
	pointer.texture = idle_sprite
	pointer.scale = Vector2.ONE
	
	if ball_in_launcher_area is Rabbitball:
		(ball_in_launcher_area as Rabbitball).anim_launcher_trail()
	elif ball_in_launcher_area is Bunnyball:
		(ball_in_launcher_area as Bunnyball).stop_start_no_limit(1.0)
		(ball_in_launcher_area as Bunnyball).anim_launcher_trail()
	
	power = launch_power * p_strength
	
	RuntimeMgr.launcher_launched.emit()


func anim_fully_charged() -> void:
	var dur := 1.2
	
	pointer.scale = Vector2.ZERO
	pointer.texture = fully_charged_sprite
	pointer.rotation = deg_to_rad(135.0 * sign(randf_range(-1.0, 1.0)))
	
	if _tween_fully_charged:
		_tween_fully_charged.kill()
	_tween_fully_charged = create_tween().set_parallel(true)
	_tween_fully_charged.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_fully_charged.tween_property(pointer,"scale",Vector2.ONE*1.4,dur)
	_tween_fully_charged.tween_property(pointer,"rotation",0.0,dur/1.25)


func ball_is_on_launcher() -> bool:
	var value: bool
	
	if ball_in_launcher_area:
		# Suggestion: `var ball_speed := ball_in_launcher_area.movement_strength`
		var ball_speed := ball_in_launcher_area.linear_velocity
		
		value = being_charged || (ball_speed.x > -300.0 && ball_speed.x < 300.0 && ball_speed.y > -400.0 && ball_speed.y < 400.0)
	
	return value


## @deprecated
func fully_charged_launch_power_added() -> bool: # Ehh?
	return fully_charged_launch_power != 0.0


func rad_to_vector(rad: float) -> Vector2:
	var x = cos(rad)
	var y = sin(rad)
	return Vector2(x, y)


func _move(delta: float) -> void:
	var charging := being_charged && _hold_timer.time_left > 0.0
	
	if charging:
		colli.position.y = _original_pos + (1.0 - _hold_timer.time_left) * ((_original_pos - _move_to) - _original_pos)
		pointer.rotation += PI * delta
	elif !PlayerInput.launcher_held:
		colli.position.y = move_toward(colli.position.y, _original_pos, delta * power)
	else:
		pass


func _state() -> void:
	if (ball_is_on_launcher() && !_is_locked_in):
		ball_entered.emit(ball_is_on_launcher())
		_is_locked_in = true
		
	if (!ball_is_on_launcher() && _is_locked_in):
		ball_entered.emit(ball_is_on_launcher())
		_is_locked_in = false


func _process(delta: float) -> void:
	_state()
	_move(delta)


func emit_particles() -> void:
	var p_r: CPUParticles2D = get_node_or_null("ParticlesRight")
	var p_l: CPUParticles2D = get_node_or_null("ParticlesLeft")
	
	if (p_l && p_r):
		for p: CPUParticles2D in [p_l, p_r]:
			if !p.emitting:
				p.emitting = true
