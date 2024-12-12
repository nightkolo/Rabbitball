class_name Door
extends StaticBody2D

@export var is_DoorSwitch_type: RuntimeMgr.DoorSwitchType:
	get:
		return is_DoorSwitch_type
	set(val):
		is_DoorSwitch_type = val
@export var reverse_role: bool = false
@export_group("Assets")
@export var cross: Texture2D = preload("res://assets/objects/door-cross-1x2.png")
@export var ringer: Texture2D = preload("res://assets/objects/door-ringer-1x2.png")

var is_actiavated: bool = false

var _colli: CollisionPolygon2D
var _colli_pos: Vector2
var _anim: AnimationPlayer
var _audio_close: AudioStreamPlayer
var _audio_open: AudioStreamPlayer
var _audio_activated: AudioStreamPlayer
var _sprite_door: Sprite2D
var _sprite_shadow: Sprite2D


func _ready() -> void:
	RuntimeMgr.door_activated.connect(_try_activate)
	RuntimeMgr.doors_deactivated.connect(_try_deactivate)
	
	_colli = get_node_or_null("CollisionPolygon2D")
	_anim = get_node_or_null("Anim")
	_audio_close = get_node_or_null("Audio/Close")
	_audio_open = get_node_or_null("Audio/Open")
	_audio_activated = get_node_or_null("Audio/Activated")
	_sprite_door = get_node_or_null("Door/Sprite2D")
	_sprite_shadow = get_node_or_null("Shadow/Sprite2D")
	
	if _sprite_door:
		setup_sprite(is_DoorSwitch_type)
		
	if _colli:
		_colli_pos = _colli.global_position
		
	if reverse_role:
		await get_tree().create_timer(0.1).timeout
		activate(is_DoorSwitch_type)


func setup_sprite(is_sprite: RuntimeMgr.DoorSwitchType) -> void:
	var type_of := RuntimeMgr.DoorSwitchType
	
	match is_sprite:
	
		type_of.CROSS:
			_sprite_door.texture = cross
			
		type_of.RINGER:
			_sprite_door.texture = ringer


func activate(is_type: RuntimeMgr.DoorSwitchType, play_sound: bool = true) -> void:
	if (!is_actiavated && is_type == is_DoorSwitch_type):
		if play_sound:
			play_close_sound()
			
		anim_activated()
		
		if _colli:
			_colli.global_position = Vector2.ZERO
		
		is_actiavated = true


func deactivate(play_sound: bool = true) -> void:
	if is_actiavated:
		if play_sound:
			play_close_sound()
		anim_deactivated()
		
		if _colli:
			_colli.global_position = _colli_pos
		
		is_actiavated = false


func _try_activate(is_type: RuntimeMgr.DoorSwitchType) -> void:
	if reverse_role:
		deactivate()
	else:
		activate(is_type)


func _try_deactivate() -> void:
	if reverse_role:
		activate(is_DoorSwitch_type, false)
	else:
		deactivate(false)


func anim_activated() -> void:
	if _anim:
		_anim.play("on")


func anim_deactivated() -> void:
	if _anim:
		_anim.play("off")


## @experimental
func play_close_sound() -> void:
	if _audio_close:
		_audio_close.play()
		_audio_activated.play()


func emit_particles() -> void:
	var p_r: CPUParticles2D = get_node_or_null("ParticlesRight")
	var p_l: CPUParticles2D = get_node_or_null("ParticlesLeft")
	
	if (p_l && p_r):
		for p: CPUParticles2D in [p_l, p_r]:
			if !p.emitting:
				p.emitting = true
