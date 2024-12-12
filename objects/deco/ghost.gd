class_name Ghost
extends Sprite2D


func _ready() -> void:
	_ghost_fade()


func set_property(set_pos: Vector2) -> void:
	global_position = set_pos


func _ghost_fade(fade_time: float = 0.5, color: Color = Color(Color.WHITE)) -> void:
	var tween_ghost_fade = get_tree().create_tween()
	
	tween_ghost_fade.tween_property(self, "self_modulate", Color(color, 0.0), fade_time)
	await tween_ghost_fade.finished
	queue_free()
