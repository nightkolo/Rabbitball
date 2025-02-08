extends Node2D
# This toke me WAY longer than it should've been, sigh, I'm exhausted honestly.
# Probable class_name Launcher

signal has_launched(strength: float)

@export var move_amount: float = 100.0

@onready var hold_timer: Timer = $HoldTimer
@onready var push_area: PhysicsManipulationArea2D = $PhysicsManipulationArea2D
@onready var colli: AnimatableBody2D = $Colli

var being_charged: bool = false

var _original_pos: Vector2


func _ready() -> void:
	_original_pos = colli.position
	
	PlayerInput.launcher_key_touched.connect(func(is_held: bool):
		if is_held:
			being_held()
		else:
			being_released()
		)
	has_launched.connect(launch)


func being_held() -> void:
	being_charged = true
	hold_timer.start()


func being_released() -> float:
	being_charged = false
	var time_held := hold_timer.time_left
	var strength := 1.0 - time_held
	hold_timer.stop()
	
	has_launched.emit(strength)
	
	return strength


func launch(p_strength: float) -> void:
	push_area.launch(Vector2(0.0, 100.0 * -p_strength))


func _move(delta: float) -> void:
	var charging := being_charged && hold_timer.time_left > 0.0
	
	# TODO: Upon looking at this, it quite possibly cause desyncing, debug it
	# Wait, I used move_toward(), nevermind the todo
	# Man, I can't read my own code sometimes lol
	if charging:
		colli.position.y += delta * move_amount
	elif !PlayerInput.launcher_held:
		colli.position.y = move_toward(colli.position.y, _original_pos.y, delta * move_amount)
	else:
		pass


func _process(delta: float) -> void:
	_move(delta)
	


	
	
	
