## [b]Warning:[/b] hes a lil kawaii ball :3
class_name ChibiBunnyball
extends Sprite2D

@export var mimick_bunnys_rotation: bool = true
@export var bunnyball: Bunnyball


func _process(_delta: float) -> void:
	if bunnyball && mimick_bunnys_rotation:
		rotation = bunnyball.rotation
		
	elif !mimick_bunnys_rotation:
		set_process(false)
