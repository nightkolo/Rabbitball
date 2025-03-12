class_name GameEndpoint
extends Area2D

@export var end_game: bool = true
@export var stop_following: bool = true


func _ready() -> void:
	collision_layer = 0
	collision_mask = 32
	
	body_entered.connect(func(body: Node2D):
		if body is Rabbitball:
			if end_game:
				UIMgr.game_end.emit()
				
			if stop_following:
				UIMgr.camera_stop.emit()
		)
