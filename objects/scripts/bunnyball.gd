class_name Bunnyball
extends Balls

@export var always_process: bool = false
@export var ghost_ball: PackedScene = preload("res://objects/deco/ghost_ball.tscn")

@onready var dust: CPUParticles2D = $Dust
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var area_detect: Area2D = $Area2D

@onready var audio_rolling: AudioStreamPlayer2D = $Audio/Rolling
@onready var audio_landed: AudioStreamPlayer2D = $Audio/Landed
@onready var audio_landed_ceiling: AudioStreamPlayer2D = $Audio/LandedCeiling

var ghost_timer: Timer = Timer.new()

var _is_on_platform: bool


func _ready() -> void:
	start_ballin()

	ghost_timer.wait_time = 0.06
	add_child(ghost_timer)
	
	ball_has_landed.connect(has_landed)
	
	area_detect.body_entered.connect(func(body: Node2D):
		if body is Platform:
			ball_has_landed.emit()
			_is_on_platform = true
		)
	area_detect.body_exited.connect(func(body: Node2D):
		if body is Platform:
			_is_on_platform = false
		)
	ghost_timer.timeout.connect(func():
		_add_ghost()
		)


func is_on_platform() -> bool:
	return _is_on_platform


func is_on_object() -> bool:
	return area_detect.get_overlapping_bodies().size() > 0


func has_landed() -> void:
	if movement_strength.y < 0.0:
		audio_landed_ceiling.play()
	else:
		audio_landed.pitch_scale = randf_range(0.8, 1.2)
		audio_landed.play()
	
	if !dust.emitting:
		dust.direction.x = sign(linear_velocity.x) * -1.0
		dust.emitting = true


func anim_launcher_trail() -> void:
	ghost_timer.start()
	await get_tree().create_timer(0.5).timeout
	ghost_timer.stop()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	apply_custom_forces(state)


func _physics_process(delta: float) -> void:
	process_ball(delta)
	emit_rolling_sounds(is_on_object(), audio_rolling)
	
	particles.emitting = is_on_platform() && is_moving()
	particles.direction.x = sign(linear_velocity.x) * -1


func _add_ghost() -> void:
	var ghost := ghost_ball.instantiate()
	ghost.set_property(global_position)
	get_tree().current_scene.add_child(ghost)
