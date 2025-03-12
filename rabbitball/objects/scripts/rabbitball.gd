class_name Rabbitball
extends Balls

@export var hide_trail: bool = false
@export var hide_ghost: bool = false
@export var self_assign_to_nodes: bool = true
@export_group("Effects")
@export var ghost_ball: PackedScene = preload("res://objects/deco/ghost_ball.tscn")

@onready var area_detect: Area2D = $Area2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var dust: CPUParticles2D = $Dust
@onready var trail: Line2D = $Trail
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sequence_player: AnimationPlayer = $Sequence

@onready var audio_rolling: AudioStreamPlayer2D = $Audio/Rolling
@onready var audio_landed: AudioStreamPlayer2D = $Audio/Landed
@onready var audio_landed_ceiling_1: AudioStreamPlayer2D = $Audio/LandedCeiling1
@onready var audio_landed_ceiling_2: AudioStreamPlayer2D = $Audio/LandedCeiling2
@onready var audio_landed_ceiling_3: AudioStreamPlayer2D = $Audio/LandedCeiling3
@onready var audio_went_through_oneway_plat: AudioStreamPlayer2D = $Audio/WentThroughOnewayPlat

var ceiling_sounds: Array[AudioStreamPlayer2D]
var ghost_timer: Timer = Timer.new()

var _is_on_platform: bool


func _ready() -> void:
	start_ballin()
	
	ceiling_sounds = [audio_landed_ceiling_1, audio_landed_ceiling_2, audio_landed_ceiling_3]
	
	trail.visible = !hide_trail
	
	if !hide_ghost:
		ghost_timer.wait_time = 0.06
		add_child(ghost_timer)
		
	if self_assign_to_nodes:
		UIMgr.rabbitball_spawned.emit(self)
		RuntimeMgr.current_rabbitball = self
	
	ball_has_landed.connect(has_landed)
	
	area_detect.body_entered.connect(func(body: Node2D):
		if (body is Platform || body is OneWayPlatform):
			ball_has_landed.emit()
			_is_on_platform = true
		)
	area_detect.body_exited.connect(func(body: Node2D):
		if (body is Platform || body is OneWayPlatform):
			_is_on_platform = false
		
		if (body is OneWayPlatform && sign(linear_velocity.y) < 0.0):
			audio_went_through_oneway_plat.play()
		)
	if !hide_ghost:
		ghost_timer.timeout.connect(_add_ghost)
	
	
func is_on_platform() -> bool:
	return _is_on_platform


func is_on_object() -> bool:
	return area_detect.get_overlapping_bodies().size() > 0


func anim_went_through_rabbithole(it_literally_went_through_the_rabbithole_object: bool = false) -> void:
	anim.play("went_through_rabbithole")
	
	if it_literally_went_through_the_rabbithole_object:
		gravity_scale = gravity_scale / 16.0
		
		await anim.animation_finished
		self.queue_free()


func anim_went_out_rabbithole(p_set_visible: bool = visible) -> void:
	anim.play("went_out_rabbithole", -1, 0.5)
	visible = p_set_visible


func anim_launcher_trail(duration_multiplier: float = 1.2) -> void:
	sequence_player.play("launcher_launched", -1, duration_multiplier)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	apply_custom_forces(state)


func has_landed() -> void:
	if movement_strength.y < 0.0:
		var aud: AudioStreamPlayer2D = ceiling_sounds[randi() % ceiling_sounds.size()]
		
		aud.pitch_scale = randf_range(0.7, 0.9)
		aud.play()
	else:
		audio_landed.pitch_scale = randf_range(0.8, 1.2)
		audio_landed.play()
	
	if !dust.emitting:
		dust.direction.x = sign(linear_velocity.x) * -1.0
		dust.emitting = true


func bumper_hit(duration_multiplier: float = 2.0) -> void:
	if anim.is_playing():
		anim.stop()
	
	anim.play("bumper_hit", -1, 0.45)
	
	if !no_limit:
		if sequence_player.is_playing():
			sequence_player.stop()
			_reset_sequence()
			
		sequence_player.play("stop_start_no_limit", -1, duration_multiplier)


func flipper_hit(duration_multiplier: float = 2.0) -> void:
	if sequence_player.is_playing():
		sequence_player.stop()
		_reset_sequence()
	sequence_player.play("flipper_hit", -1, duration_multiplier)


func start_ghost_timer(value: bool) -> void:
	_reset_sequence()
	if value:
		ghost_timer.start()
	else:
		ghost_timer.stop()


func _physics_process(delta: float) -> void:
	process_ball(delta)
	emit_rolling_sounds(is_on_object(), audio_rolling)
	
	particles.emitting = is_on_platform() && is_moving()
	particles.direction.x = sign(linear_velocity.x) * -1


func _add_ghost() -> void:
	if !hide_ghost:
		var ghost := ghost_ball.instantiate()
		ghost.set_property(position)
		get_tree().current_scene.add_child(ghost)


func _reset_sequence() -> void:
	set_main_speed(speed)
	set_main_no_limit(no_limit)
	ghost_timer.stop()
