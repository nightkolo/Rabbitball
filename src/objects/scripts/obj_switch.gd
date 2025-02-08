class_name Switch
extends Area2D

@export var is_DoorSwitch_type: RuntimeMgr.DoorSwitchType
@export var begin_hit: bool = false:
	set(val):
		# Are setter/getters redundant at this point?
		#if val:
			#hit()
		begin_hit = val

var has_been_hit: bool = false
var act_as_a_tutorial_bubble_spawn_area: bool = false ## @deprecated

var _audio_hit: AudioStreamPlayer
var _head_sprite: Sprite2D
var _base_sprite: Sprite2D
var _tween: Tween


func _ready() -> void:
	_audio_hit = get_node_or_null("AudioHit")
	_head_sprite = get_node_or_null("Head")
	_base_sprite = get_node_or_null("Base")
	
	if begin_hit:
		hit()
	
	body_entered.connect(_hit)


func _hit(body: Node2D) -> void:
	var can_be_hit := !has_been_hit && body is Balls && !act_as_a_tutorial_bubble_spawn_area
	
	if can_be_hit:
		_audio_hit.play()
		anim_hit()
		RuntimeMgr.switch_hit.emit(is_DoorSwitch_type)
		has_been_hit = true


func hit() -> void:
	await get_tree().create_timer(0.25).timeout
	if !has_been_hit:
		_audio_hit.play()
		anim_hit()
		RuntimeMgr.switch_hit.emit(is_DoorSwitch_type)
		has_been_hit = true


func anim_hit() -> void:
	if (_base_sprite && _head_sprite):
		if _tween != null:
			_tween.kill()
		_tween = get_tree().create_tween().set_parallel(true)
		_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		_tween.tween_property(_head_sprite,"scale:y",0.1,0.25)
		_tween.tween_property(_base_sprite,"scale",Vector2(0.7,0.33), 0.04)
		_tween.tween_property(_base_sprite,"scale",Vector2(0.5,0.5), 0.7).set_delay(0.04)


func anim_unhit() -> void:
	if (_base_sprite && _head_sprite):
		if _tween != null:
			_tween.kill()
		_tween = get_tree().create_tween().set_parallel(true)
		_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		_tween.tween_property(_head_sprite,"scale:y",0.5,0.3)
		_tween.tween_property(_base_sprite,"scale",Vector2(0.44,0.6), 0.04)
		_tween.tween_property(_base_sprite,"scale",Vector2(0.5,0.5), 0.7).set_delay(0.04)
