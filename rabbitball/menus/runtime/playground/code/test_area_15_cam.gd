extends Camera2D


func _ready() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"zoom",Vector2(1.4,1.4),1.2).set_delay(2.0)
