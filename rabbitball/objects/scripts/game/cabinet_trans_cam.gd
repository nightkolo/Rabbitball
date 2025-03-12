class_name CabinetPositioner
extends Node2D

@export var auto_assign_rabbitball: bool = true
@export var rabbitball: Rabbitball
@export_group("Modify")
@export var follow_rabbit: bool = true:
	get:
		return follow_rabbit
	set(val):
		set_physics_process(val)
		follow_rabbit = val
@export var emit_cabinet_changed_signal: bool = true

var no_follow: bool = false:
	set(val):
		no_follow = val
		if val == false:
			_update_cabinet(parent_cabinet)
var current_cabinet: Vector2 = Vector2.ZERO
var parent_cabinet: Vector2 = Vector2.ZERO

var _ear: PackedScene = preload("res://objects/game/audio_listener_2d.tscn")
var _screen_size: Vector2 = UIMgr.SCREEN_SIZE


func _ready() -> void:
	UIMgr.rabbitball_spawned.connect(func(is_rb: Rabbitball):
		if follow_rabbit && auto_assign_rabbitball:
			rabbitball = is_rb
		)
	UIMgr.camera_stop.connect(func():
		follow_rabbit = false
		)
	
	var ear := _ear.instantiate() as AudioListener2D
	add_child(ear)
		
	if follow_rabbit:
		_update_cabinet(current_cabinet)
	else:
		set_physics_process(follow_rabbit)
	
	top_level = true


## @experimental
func move_to_cabinet(cab: Cabinet) -> void:
	if follow_rabbit == false:
		global_position = cab.global_position
	

func _update_cabinet(new_cab: Vector2) -> void:
	current_cabinet = new_cab
	
	if !no_follow:
		global_position = _screen_size * current_cabinet
		
		if emit_cabinet_changed_signal:
			UIMgr.current_cabinet_coordinates_changed.emit(current_cabinet)


func _physics_process(_delta: float) -> void:
	if rabbitball:
		parent_cabinet = (rabbitball.global_position / _screen_size).floor()
		
		if parent_cabinet != current_cabinet:
			_update_cabinet(parent_cabinet)
