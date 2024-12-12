## You might be looking for [url]res://objects/scripts/obj_launcher.gd[\url]
extends Node2D


signal has_launched(strength: float)
signal has_fully_charged()

@export var launch_power: float = 520.0:
	get:
		return 2.0 * launch_power
@export var buffer_input_time: float = 0.15
@export_group("Assets")
@export var idle_sprite: Texture2D = preload("res://assets/objects/launcher-pointer-01.png")
@export var fully_charged_sprite: Texture2D = preload("res://assets/objects/launcher-pointer-02.png")

@onready var anim: AnimationPlayer = $Anim
@onready var pointer: Sprite2D = $Head/PointerSprite

var release_speed: float = 500.0
var being_charged: bool = false
var buffered_input: bool = false
var ball_in_launcher_area: Balls

var _hold_timer: Timer = Timer.new()
var _buffer_input_timer: Timer = Timer.new()
var _tween: Tween
var _original_pos: float
var _move_to: float


func _ready() -> void:
	_hold_timer.wait_time = 0.75
	_hold_timer.one_shot = true
	_buffer_input_timer.wait_time = buffer_input_time
	_buffer_input_timer.one_shot = true
	add_child(_hold_timer)
	add_child(_buffer_input_timer)
	
	#_original_pos = colli.position.y
	#_move_to = _original_pos - 24.0
	
	has_launched.connect(launch)
	has_fully_charged.connect(anim_fully_charged)
	
	#PlayerInput.launcher_key_touched.connect(func(is_held: bool):
		#if ball_is_on_launcher():
			#hold_or_release(is_held)
			#)
	#if push_area:
		#push_area.ball_landed_in_launcher.connect(func(_strength: float):
			#hold_or_release(buffered_input)
			#)
	#if launcher_area:
		#launcher_area.body_entered.connect(func(body: Node2D):
			#if body is Balls:
				#ball_in_launcher_area = (body as Balls)
			#)
		#launcher_area.body_exited.connect(func(body: Node2D):
			#if body is Balls:
				#ball_in_launcher_area = null
			#)
	_buffer_input_timer.timeout.connect(func():
		buffered_input = false
		)
	_hold_timer.timeout.connect(func():
		has_fully_charged.emit()
		)


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("launcher"):
		#buffered_input = true
		#_buffer_input_timer.start()
	#
	#if !_buffer_input_timer.is_stopped():
		#if event.is_action_released("launcher"):
			#buffered_input = false
			#_buffer_input_timer.stop()


func hold_or_release(input_hold: bool) -> void:
	if input_hold:
		if !being_charged:
			anim.play("charge_up", -1, 1.5)
			_hold_timer.start()
			being_charged = true
	else:
		if being_charged:
			var time_elapsed_held := _hold_timer.time_left
			var strength := 0.5 - time_elapsed_held
			_hold_timer.stop()
			
			has_launched.emit(strength * 2.0)
			
			being_charged = false


func launch(_p_strength: float) -> void:
	if _p_strength == 1.0:
		anim.play("launch_full")
	else:
		anim.play("launch_half")
	pointer.texture = idle_sprite
	#ball_in_launcher_area.stop_start_no_limit(1.0)
	
	if ball_in_launcher_area is Rabbitball:
		(ball_in_launcher_area as Rabbitball).anim_launcher_trail()
	elif ball_in_launcher_area is Bunnyball:
		(ball_in_launcher_area as Bunnyball).anim_launcher_trail()
		
	#RuntimeMgr.launcher_launched.emit()
	#push_area.launch(Vector2(0.0, launch_power * -p_strength * 2.0))


func ball_is_on_launcher() -> bool:
	return true


func _move(delta: float) -> void:
	var charging := being_charged && _hold_timer.time_left > 0.0
	#
	if charging:
		#colli.position.y = _original_pos + (1.0 - _hold_timer.time_left) * ((_original_pos - _move_to) - _original_pos)
		pointer.rotation += TAU * delta
	elif !PlayerInput.launcher_held:
		pass
		#colli.position.y = move_toward(colli.position.y, _original_pos, delta * release_speed)
	else:
		pass
#

func _process(delta: float) -> void:
	_move(delta)


func anim_fully_charged() -> void:
	pointer.scale = Vector2.ZERO
	pointer.texture = fully_charged_sprite
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(pointer, "scale", Vector2.ONE, 1.0)


func emit_particles() -> void:
	var p_r: CPUParticles2D = get_node_or_null("ParticlesRight")
	var p_l: CPUParticles2D = get_node_or_null("ParticlesLeft")
	
	if (p_l && p_r):
		for p: CPUParticles2D in [p_l, p_r]:
			if !p.emitting:
				p.emitting = true
