extends Button

var _tween: Tween


func _ready() -> void:
	self.add_to_group("UIButton")
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pivot_offset = size/2.0
	
	mouse_entered.connect(_hover)
	mouse_exited.connect(_hover_out)
	focus_entered.connect(_hover)
	focus_exited.connect(_hover_out)
	button_down.connect(_held)
	button_up.connect(_rest)
	pressed.connect(_pressed)
	
	
func _hover() -> void:
	#if !Audio.ui_button_hover.playing:
	Audio.ui_button_hover.play()
	self.scale = Vector2.ONE/2.0
	_reset_tween()
	_tween = get_tree().create_tween().set_parallel(true)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(self,"scale:x",1.3,1.04)
	_tween.tween_property(self,"scale:y",1.3,1.04).set_delay(0.078)
	
	
func _hover_out() -> void:
	_reset_tween()
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(self,"scale",Vector2.ONE,1.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _held() -> void:
	set("theme_override_colors/font_outline_color",Color(Color.WHITE))
	
	
func _rest() -> void:
	set("theme_override_colors/font_outline_color",Color("323232"))


func _pressed() -> void:
	if !Audio.ui_button_click.playing:
		Audio.ui_button_click.play()
	_reset_tween()
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self,"scale",Vector2(1.75,0.3),0.06)
	_tween.tween_property(self,"scale",Vector2(1.3,1.3),1.04).set_trans(Tween.TRANS_ELASTIC)


func _reset_tween() -> void:
	if _tween != null:
		_tween.kill()
