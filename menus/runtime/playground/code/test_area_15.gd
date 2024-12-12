extends Node2D

@onready var cam: Camera2D = $Cam


func _ready() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(cam,"zoom",Vector2(1.2,1.2),1.0).set_delay(2.0)
