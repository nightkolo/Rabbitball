extends Button

var _tween: Tween


func _ready() -> void:
	self.add_to_group("CabinetButton")
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pivot_offset = size/2.0
	rotation_degrees = randf_range(90.0,-90.0)
	
	mouse_entered.connect(_hover)
	mouse_exited.connect(_hover_out)
	focus_entered.connect(_hover)
	focus_exited.connect(_hover_out)
	button_down.connect(_held)
	button_up.connect(_rest)
	pressed.connect(_pressed)
	
	
func _hover() -> void:
	#if !Audio.ui_button_hover.playing:
	Audio.emit_level_button_hover()
	self.scale = Vector2(0.25,4.0)
	self.rotation_degrees = randf_range(-90.0,90.0)
	_reset_tween()
	_tween = get_tree().create_tween().set_parallel(true)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(self,"scale",Vector2(1.9,1.9),0.85)
	_tween.tween_property(self,"rotation_degrees",0.0,0.5)
	
	
func _hover_out() -> void:
	_reset_tween()
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	self.scale = Vector2.ONE*3.0
	self.rotation_degrees = 0.0
	_tween.tween_property(self,"scale",Vector2.ONE,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)


func _held() -> void:
	set("theme_override_colors/font_outline_color",Color(Color.WHITE))
	
	
func _rest() -> void:
	set("theme_override_colors/font_outline_color",Color("323232"))


func _pressed() -> void:
	if !Audio.ui_button_click.playing:
		Audio.game_start.play()
	_reset_tween()
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	self.rotation_degrees = 0.0
	_tween.tween_property(self,"scale",Vector2(1.1,1.1),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _reset_tween() -> void:
	if _tween != null:
		_tween.kill()
