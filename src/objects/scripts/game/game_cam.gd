class_name LightCameraPanner
extends Camera2D

@export var ball: Rabbitball
@export var smooth_camera: bool = true

var pan_to_ball: bool = true:
	get:
		return pan_to_ball
	set(val):
		if val == dynamic_camera_setting:
			if val:
				zoom = Vector2(1.16, 1.16)
			else:
				zoom = Vector2.ONE
				position = Vector2.ZERO
			set_process(val)
			pan_to_ball = val
var dynamic_camera_setting: bool = UIMgr.get_dynamic_camera_on_setting():
	set(value):
		dynamic_camera_setting = value
		pan_to_ball = value

var _cam_min := Vector2.ZERO
var _cam_max := Vector2(124.0, 99.0)

var _ball_min := Vector2.ZERO
var _ball_max := Vector2(900.0, 720.0)


func _ready() -> void:
	pan_to_ball = dynamic_camera_setting
	
	UIMgr.dynamic_camera_option_set.connect(func(on: bool):
		dynamic_camera_setting = on
		)
	
	UIMgr.rabbitball_spawned.connect(func(ref: Rabbitball):
		ball = ref
		)
		
	UIMgr.camera_stop.connect(func():
		set_process(false)
		)
	
	if !pan_to_ball:
		set_process(false)
		zoom = Vector2.ONE
		position = Vector2.ZERO
	
	# If all else fails.
	if ball == null:
		if get_parent() is CabinetPositioner:
			ball = (get_parent() as CabinetPositioner).rabbitball
			
	await get_tree().create_timer(1.0).timeout
	position_smoothing_enabled = smooth_camera
	if position_smoothing_enabled:
		position_smoothing_speed = 10.0


func _pan_to_rabbitball(p_ball: Rabbitball) -> void:
	var ballpos_rel_to_cam := p_ball.global_position - self.global_position
	var pan_to := _cam_min + (ballpos_rel_to_cam / _ball_max) * (_cam_max - _cam_min)
	
	position = pan_to


func _process(_delta: float) -> void:
	if ball:
		_pan_to_rabbitball(ball)
