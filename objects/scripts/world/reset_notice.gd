## Yes, the reference was intented.
class_name Resetti
extends Node2D

var _tween: Tween


func _ready() -> void:
	RuntimeMgr.current_reset_notice = self


func _process(delta: float) -> void:
	if RuntimeMgr.current_rabbitball:
		global_position = global_position.lerp(Vector2(0.0,-36.0) + RuntimeMgr.current_rabbitball.global_position, delta * 16.0) 
		
#		$Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, delta * FOLLOW_SPEED)


func show_notice() -> void:
	await get_tree().create_timer(0.5).timeout
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self,"modulate",Color(Color.WHITE, 1.0),1.0)


func remove_notice() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self,"modulate",Color(Color.WHITE, 0.0),1.0)
	await _tween.finished
	self.queue_free()
