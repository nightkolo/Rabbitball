## Used only for the short cutscene in the intro.
class_name Bubble
extends MarginContainer

@onready var bubble: MarginContainer = $Bubble
@onready var bubble_rect: NinePatchRect = %NinePatchRect
@onready var anim: AnimationPlayer = $Anim

var is_animating: bool = true

var _initial_pos: Vector2
var _tween_shape: Tween
var _tween_startup: Tween
var _current_size: Vector2
var _old_size: Vector2


func _ready() -> void:
	_initial_pos = position
	
	#bubble_rect.pivot_offset = Vector2(size.x / 2, size.y)
	bubble_rect.scale = Vector2.ZERO
	bubble_rect.self_modulate = Color(Color.WHITE, 0.0)
	_anim_startup()


func size_to(p_size: Vector2) -> void:
	_current_size = p_size
	size = p_size
	
	_reposition(p_size)
	anim_shape_changed(p_size)


func anim_shape_changed(p_size_to: Vector2) -> void:
	if !is_animating:
		bubble_rect.pivot_offset = Vector2(p_size_to.x / 2, p_size_to.y)
		if _tween_shape:
			_tween_shape.kill()
		_tween_shape = create_tween().set_parallel(false)
		_tween_shape.set_ease(Tween.EASE_OUT)
		_tween_shape.tween_property(bubble_rect,"scale",Vector2(1.25,0.7),0.04)
		_tween_shape.tween_property(bubble_rect,"scale",Vector2(1.0,1.0),0.5).set_trans(Tween.TRANS_BACK)


func anim_letter_show() -> void:
	bubble.pivot_offset = Vector2(_current_size.x / 2, _current_size.y)
	#print("banana")
	anim.play("letter_shown", -1, 0.75)


func anim_finished(remove_on_finished: bool = true) -> void:
	is_animating = true
	if _tween_startup:
		_tween_startup.kill()
	_tween_startup = create_tween().set_parallel(true)
	_tween_startup.set_ease(Tween.EASE_IN)
	_tween_startup.tween_property(bubble_rect,"scale:y",0.0,0.3).set_trans(Tween.TRANS_BACK)
	_tween_startup.tween_property(bubble_rect,"scale:x",0.0,0.3).set_trans(Tween.TRANS_EXPO)
	_tween_startup.tween_property(bubble_rect,"self_modulate",Color(Color.WHITE,0.0),0.3)
	await _tween_startup.finished
	if remove_on_finished:
		self.queue_free()
	else:
		is_animating = false


func _reposition(p_size_to: Vector2) -> void:
	pivot_offset.x = p_size_to.x / 2
	pivot_offset.y = p_size_to.y
	position.x = _initial_pos.x - p_size_to.x / 2
	position.y = _initial_pos.y - p_size_to.y - 26.0


func _anim_startup() -> void:
	var dur := 2.0
	is_animating = true
	await get_tree().create_timer(0.1).timeout
	bubble_rect.scale = Vector2(0.4,0.0)
	bubble_rect.pivot_offset = Vector2(_current_size.x / 2, _current_size.y)
	#bubble_rect.self_modulate = Color(Color.WHITE, 0.85)
	if _tween_startup:
		_tween_startup.kill()
	_tween_startup = create_tween().set_parallel(true)
	_tween_startup.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_startup.tween_property(bubble_rect,"self_modulate",Color(Color.WHITE, 0.85),0.75)
	_tween_startup.tween_property(bubble_rect,"scale:y",1.0,dur)
	_tween_startup.tween_property(bubble_rect,"scale:x",1.0,dur).set_delay(dur/(40.0/3.0))
	await _tween_startup.finished
	is_animating = false
