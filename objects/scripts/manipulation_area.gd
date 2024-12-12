class_name PhysicsManipulationArea2D
extends Area2D

## Currently has issues with late calling.
signal ball_landed_in_launcher(at_strength: float)

enum Ball {ALL = 0, RABBIT = 1, BUNNY = 2}
enum ManipulationEffect {
	## Apply custom behavior
	CUSTOM = 0,
	## Slows down detected ball, of [Balls].
	SLOW_DOWN = 1,
	## Speeds up detected ball, of [Balls].
	SPEED_UP = 2,
	## Cancels velocity of detected ball, of [Balls].
	PAUSE = 3}

@export var manipulate: bool = true:
	get:
		return manipulate
	set(val):
		manipulate = val
@export var look_for: Ball
@export var effect: ManipulationEffect
## Only relevant for [enum ManipulationEffect.SLOW_DOWN], [enum ManipulationEffect.SPEED_UP].
@export var by_factor: float = 2.0
## Only relevant for [enum ManipulationEffect.CUSTOM].
@export var move_to: Vector2 = Vector2.ZERO

## @experimental: Used by [Launcher].
var act_as_a_launcher: bool = false:
	set(val):
		manipulate = !val
		act_as_a_launcher = val

var ball_is_in_area: bool = false
var ball_in_area: Balls

var _original_pos: Vector2


func _ready() -> void:
	collision_layer = 0
	collision_mask = 48
	
	_original_pos = position
	
	body_entered.connect(func(body: Node2D):
		if !act_as_a_launcher:
			if manipulate:
				var can_manipulate: bool
				
				match look_for:
					Ball.ALL:
						can_manipulate = body is Balls
						
					Ball.RABBIT:
						can_manipulate = body is Rabbitball
						
					Ball.BUNNY:
						can_manipulate = body is Bunnyball
				
				if can_manipulate:
					_manipulate(body, by_factor)
		else:
			## These lines are largely deprecated, but kept for legacy purposes.
			if body is Balls:
				var ball: Balls = body
				var low_speed := ball.linear_velocity / 5.0
				
				ball_in_area = ball
				ball_is_in_area = true
				ball_landed_in_launcher.emit(ball.linear_velocity.y)
				RuntimeMgr.rabbitball_manipulated.emit()
				(body as Balls).linear_velocity = low_speed
		)
	## Same with this.
	if act_as_a_launcher:
		body_exited.connect(func(body: Node2D):
			if body is Balls:
				ball_in_area = null
				ball_is_in_area = false
			)


## @deprecated
func launch(strength: Vector2) -> void:
	if (act_as_a_launcher && ball_in_area):
		RuntimeMgr.rabbitball_manipulated.emit()
		ball_in_area.stop_start_no_limit(1.0)
		ball_in_area.linear_velocity = strength


func _manipulate(ball: Balls, scale_factor: float = 5.0) -> void:
	RuntimeMgr.rabbitball_manipulated.emit()
	match effect:
		
		ManipulationEffect.CUSTOM:
			ball.linear_velocity = move_to
			
		ManipulationEffect.SLOW_DOWN:
			ball.linear_velocity = ball.linear_velocity / scale_factor
			
		ManipulationEffect.SPEED_UP:
			ball.linear_velocity = ball.linear_velocity * scale_factor
			
		ManipulationEffect.PAUSE:
			ball.linear_velocity = Vector2.ZERO
