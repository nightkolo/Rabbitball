extends Button

var _tween: Tween

func _ready() -> void:
	self.add_to_group("UIButton")
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pivot_offset = size/2
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
	self.scale = Vector2(0.9,0.9) # Too bouncy AAAAA
	_reset_tween()
	_tween = get_tree().create_tween().set_parallel()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(self,"scale:x",1.16,0.83)
	_tween.tween_property(self,"scale:y",1.16,0.83).set_delay(0.0625)
	
func _hover_out() -> void:
	_reset_tween()
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(self,"scale",Vector2.ONE,0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

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
	_tween.tween_property(self,"scale",Vector2(1.4,0.8),0.05)
	_tween.tween_property(self,"scale",Vector2(1.16,1.16),0.9).set_trans(Tween.TRANS_ELASTIC)

func _reset_tween() -> void:
	if _tween != null:
		_tween.kill()
