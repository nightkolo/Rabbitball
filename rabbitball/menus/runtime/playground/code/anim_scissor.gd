extends Button

@onready var scissor: Node2D = get_parent()

var _tween: Tween

var original_pos: float = 0.0
var move_to: float = 80.0

func _ready() -> void:
	button_down.connect(func():
		var distance: float = abs(rad_to_deg(scissor.rotation) - move_to) / move_to
		
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(scissor, "rotation", deg_to_rad(move_to), distance / 3)
		await _tween.finished
		scissor.anim.play("hold")
		)

	button_up.connect(func():
		var distance: float = rad_to_deg(scissor.rotation) / move_to
		
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(scissor, "rotation", deg_to_rad(original_pos), distance / 3)
		await _tween.finished
		scissor.anim.play("rest")
		)
