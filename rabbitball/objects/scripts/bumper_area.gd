class_name BumperArea
extends Node2D

@onready var areas: Array[Node] = get_children()

@export var push: bool = true
@export var push_strength: float = 1000.0
var fixed_push: bool = false
var push_toward: Vector2 = Vector2.ZERO

var _bumper: Bumper


func _ready() -> void:
	visible = true
	
	if get_parent() is Bumper:
		_bumper = (get_parent() as Bumper)
	
	for area: Area2D in areas:
		area.body_entered.connect(func(body: Node2D):
			var can_manipulate_ball := push && body is Balls
			
			if can_manipulate_ball:
				#RuntimeMgr.bumper_hit.emit()
				if body is Rabbitball:
					(body as Rabbitball).bumper_hit()
				
				if _bumper:
					pass
					#_bumper.anim_bounce()
					#_bumper.play_bounce_sound()
					
				if !fixed_push:
					(body as Balls).linear_velocity = rad_to_vector(area.rotation) * push_strength
				else:
					(body as Balls).linear_velocity = push_toward
		)


func rad_to_vector(rad: float) -> Vector2:
	var x = cos(rad)
	var y = sin(rad)
	return Vector2(x, y)
	
