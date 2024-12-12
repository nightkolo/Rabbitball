extends Node2D

@onready var star_scale: Node2D = $StarP
@onready var star: Sprite2D = $StarP/Star
@onready var star_ghost: Sprite2D = $StarGhost

var _tween_up: Tween
var _tween_down: Tween
var _tween_full: Tween

var scale_to: Vector2 = Vector2(0.9,0.9)/2
var origi_scale: Vector2 = Vector2.ZERO

func anim_up() -> void:
	var scale_in := 0.2
	var distance := 1.0 - (star.scale.x / scale_to.x)
	if _tween_down:
		_tween_down = null
	star.rotation_degrees = -60.0
	_tween_up = create_tween()
	_tween_up.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	_tween_up.tween_property(
		star,
		"scale",
		scale_to,
		distance/5)
	_tween_up.tween_property(
		star,
		"rotation_degrees",
		0.0,
		1.25).from(star.rotation_degrees).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	await get_tree().create_timer(scale_in).timeout
	if _tween_up:
		_anim_full()
	
	
func anim_down() -> void:
	var scale_out := 0.2
	if _tween_up:
		_tween_up = null
	_tween_down = create_tween()
	_tween_down.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	_tween_down.tween_property(
		star,
		"scale",
		origi_scale,
		scale_out)
	_tween_down.tween_property(
		star,
		"rotation_degrees",
		-60.0,
		scale_out).from(star.rotation_degrees)


func _anim_full() -> void:
	if _tween_full:
		_tween_full.kill()
	star_ghost.scale = Vector2.ONE/2
	star_ghost.self_modulate = Color(Color.WHITE, 0.6)
	_tween_full = create_tween()
	_tween_full.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel(true)
	_tween_full.tween_property(
		star_ghost,
		"scale",
		Vector2(0.7,0.7),
		0.8).set_trans(Tween.TRANS_EXPO)
	_tween_full.tween_property(
		star_ghost,
		"self_modulate",
		Color(Color.WHITE, 0.0),
		0.9).set_trans(Tween.TRANS_EXPO)
	_tween_full.tween_property(
		star_scale,
		"scale",
		Vector2(1.3,1.3),
		0.08)
	_tween_full.tween_property(
		star_scale,
		"scale",
		Vector2.ONE,
		0.35).set_delay(0.08)
