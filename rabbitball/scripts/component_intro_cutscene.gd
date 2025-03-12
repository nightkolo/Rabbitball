@tool
class_name IntroCutsceneComponent
extends Node

@onready var cabinet_cam: CabinetPositioner = get_parent() as CabinetPositioner

var move_from: float = -1080.0
var move_to: float = -720.0

var _cam: LightCameraPanner
var _cam_is_panning: bool
var _tween: Tween
var _parent: Node


func _get_configuration_warnings() -> PackedStringArray:
	if _parent is not CabinetPositioner:
		return ["This node must be a child of CabinetPositioner."]
	else:
		return []


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_parent = get_parent()
		update_configuration_warnings()


func _ready() -> void:
	#if UIMgr.LEVEL_NAME == &"Intro":
	#await get_tree().create_timer(0.2).timeout
	
	if UIMgr.LEVEL_ID == 101:
		if (cabinet_cam is CabinetPositioner && cabinet_cam != null):
			Audio.emit_game_start_sound()
			cabinet_cam.no_follow = true
			cabinet_cam.position.y = -1080.0
			
			if cabinet_cam.get_node_or_null("Cam") is LightCameraPanner:
				_cam = cabinet_cam.get_node_or_null("Cam") as LightCameraPanner
				_cam_is_panning = UIMgr.get_dynamic_camera_on_setting()
				_cam.dynamic_camera_setting = false
				_cam.position_smoothing_enabled = false
				_cam.zoom = Vector2(1.1, 1.1)
				_cam.position.x = 81.0/2.0
			
			anim_cutcene()
			
		else:
			push_error(str(self) + " is not a child of CabinetPositioner.")


func anim_cutcene() -> void:
	var dur := 7.0
	var delay := 1.0 + UIMgr.INTRO_CUTSCENE_ANIMS_WAITTIME
		
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(cabinet_cam, "position:y", move_to, dur).from(move_from).set_delay(delay)
	if _cam:
		_tween.tween_property(_cam, "position:y", 64.0, dur).from_current().set_delay(delay)
	await _tween.finished
	cabinet_cam.no_follow = false
	if _cam:
		_cam.position_smoothing_enabled = true
	await UIMgr.current_cabinet_coordinates_changed
	if _cam:
		_cam.dynamic_camera_setting = UIMgr.get_dynamic_camera_on_setting()
