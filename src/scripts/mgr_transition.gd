extends CanvasLayer

@onready var _trans_anim: AnimationPlayer = $TransAnim

## omg I'm so proud bestie!!!!
var is_transitioning: bool


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	_trans_anim.animation_finished.connect(func(_anim_name: StringName):
		is_transitioning = false
		)


func bars_to_scene(scene: String, fade_in_speed: float = 1.0, fade_out_speed: float = fade_in_speed, hangtime: float = 0.0) -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	_trans_anim.play("bars_in", -1, fade_in_speed)
	($Tran1 as Node2D).visible = true
	
	await _trans_anim.animation_finished
	get_tree().change_scene_to_file(scene)
	await get_tree().create_timer(hangtime).timeout
	_trans_anim.play("bars_out", -1, fade_out_speed)
	
	await _trans_anim.animation_finished
	($Tran1 as Node2D).visible = false
	
	
func sidebars_to_scene(scene: String, fade_in_speed: float = 1.0, fade_out_speed: float = fade_in_speed, hangtime: float = 0.0) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	_trans_anim.play("sidebars_in", -1, fade_in_speed)
	($Tran4 as Node2D).visible = true
	
	await _trans_anim.animation_finished
	get_tree().change_scene_to_file(scene)
	await get_tree().create_timer(hangtime).timeout
	_trans_anim.play("sidebars_out", -1, fade_out_speed)
	#_trans_anim.play_backwards("sidebars_in")
	
	await _trans_anim.animation_finished
	($Tran4 as Node2D).visible = false


func fade_to_scene(scene: String, fade_in_speed: float = 1.0, fade_out_speed: float = fade_in_speed, hangtime: float = 0.0) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	_trans_anim.play("fade_in", -1, fade_in_speed)
	($Tran3 as Node2D).visible = true
	
	await _trans_anim.animation_finished
	get_tree().change_scene_to_file(scene)
	await get_tree().create_timer(hangtime).timeout
	_trans_anim.play("fade_out", -1, fade_out_speed)
	
	await _trans_anim.animation_finished
	($Tran3 as Node2D).visible = false


func reset_cabinet() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	_trans_anim.play("reset_fade_in")
	($Tran2 as Node2D).visible = true
	
	await _trans_anim.animation_finished
	UIMgr.game_reset.emit()
	await get_tree().create_timer(0.1).timeout
	_trans_anim.play_backwards("reset_fade_in")
	
	await _trans_anim.animation_finished
	($Tran2 as Node2D).visible = false
