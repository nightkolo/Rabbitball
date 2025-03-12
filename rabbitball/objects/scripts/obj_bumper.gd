class_name Bumper
extends AnimatableBody2D

@export var disable_bumper_area: bool = false
@export var push_strength: float = 1000.0
@export var fixed_push: bool = false
@export var push_toward: Vector2

var _tween: Tween
var _anim: AnimationPlayer
var _bumper_area: BumperArea
var _area: Area2D
var _sprite: Sprite2D
var _sprite_shadow: Sprite2D
var _audio: Node
var _audio_nodes: Array[Node] = []


func _ready() -> void:
	_bumper_area = get_node_or_null("BumperArea")
	_anim = get_node_or_null("Node/Anim")
	_sprite = get_node_or_null("Sprite2D")
	_sprite_shadow = get_node_or_null("Shadow")
	_area = get_node_or_null("Area2D")
	_audio = get_node_or_null("Audio")
	
	if _bumper_area:
		_bumper_area.visible = true
		_bumper_area.push = !disable_bumper_area
		_bumper_area.push_strength = push_strength
		_bumper_area.fixed_push = fixed_push
		_bumper_area.push_toward = push_toward
		
	if _audio:
		_audio_nodes = _audio.get_children()
		
	if _area:
		_area.body_entered.connect(func(body: Node2D):
			if body is Rabbitball:
				anim_bounce()
				play_bounce_sound()
			)


func anim_bounce() -> void:
	if (_sprite && _sprite_shadow):
		var dur := 1.5
		var delay := dur / 23.33
		
		_sprite.scale = Vector2(0.05,0.05)
		_sprite_shadow.scale = Vector2(0.05,0.05)
		
		if _anim:
			_anim.play("bounce", -1, 1.05)
		if _tween:
			_tween.kill()
		_tween = get_tree().create_tween().set_parallel(true)
		_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		_tween.tween_property(_sprite, "scale:x", 0.5, dur)
		_tween.tween_property(_sprite_shadow, "scale:y", 0.5, dur)
		_tween.tween_property(_sprite, "scale:y", 0.5, dur).set_delay(delay)
		_tween.tween_property(_sprite_shadow, "scale:x", 0.5, dur).set_delay(delay)


func play_bounce_sound():
	if !_audio_nodes.is_empty():
		var aud: AudioStreamPlayer = _audio_nodes[randi() % _audio_nodes.size()]
		aud.play()


func emit_particles() -> void:
	pass


func preview_loop_anim() -> void:
	anim_bounce()
	await get_tree().create_timer(2.0).timeout
	preview_loop_anim()
