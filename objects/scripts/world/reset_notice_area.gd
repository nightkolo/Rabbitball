class_name ResetNotice
extends Area2D

@export var open: bool = true
## @experimental: Currently doesn't work for [member Door.reverse_role] doors.
@export var if_this_door_is_closed: Door
@export var waittime_to_appear: float = 2.0:
	set(value):
		if value == 0.0:
			waittime_to_appear = 0.1
		waittime_to_appear = value


func _ready() -> void:
	collision_layer = 0
	collision_mask = 32
	
	body_entered.connect(func(body: Node2D):
		if body is Rabbitball:
			if open:
				if if_this_door_is_closed:
					if !if_this_door_is_closed.is_actiavated:
						
						await get_tree().create_timer(waittime_to_appear).timeout
						RuntimeMgr.open_reset_notice()
				else:
					await get_tree().create_timer(waittime_to_appear).timeout
					RuntimeMgr.open_reset_notice()
				
			elif !open:
				RuntimeMgr.close_reset_notice()
		)
