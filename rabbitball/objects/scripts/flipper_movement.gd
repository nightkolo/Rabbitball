class_name FlipperMover
extends Flipper

signal has_moved(is_held: bool) ## @deprecated

enum ManipulationMode {OFF = 0, PUSH_ON_REST = 1, PUSH_ON_HOLD = 2, STABLE_ON_REST = 3, STABLE_ON_HOLD = 4}

@export var move_to: Vector2 = Vector2(0.0, 0.0)
@export var emit_signal_on_hold: bool = true 
@export_group("Modify")
@export var manipulate: ManipulationMode = ManipulationMode.OFF
@export_range(0.0, 2.0, 0.05, "or_greater", "or_less") var manipulation_multiplier: float = 1.0
@export var one_way_collision: bool = false
@export var push_off_limits: bool = true
@export var draw_endpoint: bool = true
@export_subgroup("Miscellaneous")
@export var count_onscreen: bool = true

var manipulate_to: Vector2
var rabbitball_in_flipper: Rabbitball
var bunnyball_in_flipper: Bunnyball
var balls_in_flipper: Array[Balls]
var ball_is_in_flipper: bool ## @deprecated
var ball_in_flipper: Balls: ## @deprecated
	get:
		return ball_in_flipper
	set(value):
		ball_in_flipper = value
		if value != null:
			ball_is_in_flipper = true
		else:
			ball_is_in_flipper = false

var _onscreen: PackedScene = preload("res://objects/handlers/flipper_mover_onscreen.tscn")
var _area: Area2D
var _sprite: Sprite2D
var _colli: CollisionPolygon2D
var _original_pos: Vector2


func _ready() -> void:
	start_flippin()
	set_manipulation()
	_update_balls_in_flipper()
	
	if count_onscreen:
		var onscreen := _onscreen.instantiate()
		add_child(onscreen)
	
	_original_pos = position
	_sprite = get_node_or_null("Sprite2D")
	_area = get_node_or_null("Area2D")
	_colli = get_node_or_null("CollisionPolygon2D")
	
	if push_off_limits:
		match get_flipper_type():
			
			RuntimeMgr.FlipperType.A:
				PlayerInput.flipper_A_touched.connect(func(is_held: bool):
					if is_held == emit_signal_on_hold:
						#RuntimeMgr.flipper_hit.emit()
						if rabbitball_in_flipper:
							rabbitball_in_flipper.flipper_hit()
							
						if bunnyball_in_flipper:
							bunnyball_in_flipper.flipper_hit()
					)
					
			RuntimeMgr.FlipperType.B:
				PlayerInput.flipper_B_touched.connect(func(is_held: bool):
					if is_held == emit_signal_on_hold:
						#RuntimeMgr.flipper_hit.emit()
						if rabbitball_in_flipper:
							rabbitball_in_flipper.flipper_hit()
							
						if bunnyball_in_flipper:
							bunnyball_in_flipper.flipper_hit()
					)
	if _sprite:
		_sprite.self_modulate = get_flipper_color()
		
		if draw_endpoint:
			var end_point := _sprite.duplicate() as Sprite2D
			end_point.self_modulate = Color(Color.WHITE, 0.125)
			end_point.top_level = true
			end_point.z_index = -4
			
			if (get_initial_flipper_type() == 2 && parent_flipper):
				end_point.position = global_position + parent_flipper.move_to
			else:
				end_point.position = global_position + move_to
				
			add_child(end_point)
	if _area:
		var area := setup_area(_area)
		
		area.body_entered.connect(func(body: Node2D):
			if body is Rabbitball:
				rabbitball_in_flipper = body as Rabbitball
			elif body is Bunnyball:
				bunnyball_in_flipper = body as Bunnyball
				
			_update_balls_in_flipper()
			)
		area.body_exited.connect(func(body: Node2D):
			if body is Rabbitball:
				rabbitball_in_flipper = null
			elif body is Bunnyball:
				bunnyball_in_flipper = null
				
			_update_balls_in_flipper()
			)
	if _colli:
		_colli.one_way_collision = one_way_collision


func set_manipulation() -> Vector2:
	if (parent_flipper && move_to == Vector2.ZERO):
		manipulate_to = parent_flipper.move_to * manipulation_multiplier
	else:
		manipulate_to = move_to * manipulation_multiplier
	
	match manipulate:
		
		ManipulationMode.OFF:
			pass
		
		ManipulationMode.PUSH_ON_HOLD:
			flipper_reached_end.connect(func():
				for ball: Balls in balls_in_flipper:
					if ball:
						ball.linear_velocity = 20.0 * Vector2(manipulate_to.x, -manipulate_to.y)
				)
		
		ManipulationMode.PUSH_ON_REST: 
			flipper_reached_start.connect(func():
				for ball: Balls in balls_in_flipper:
					if ball:
						ball.linear_velocity = 20.0 * Vector2(-manipulate_to.x, -manipulate_to.y)
				)
		
		ManipulationMode.STABLE_ON_HOLD:
			flipper_reached_end.connect(func():
				for ball: Balls in balls_in_flipper:
					if ball:
						ball.linear_velocity = Vector2.ZERO
				)

		ManipulationMode.STABLE_ON_REST:
			flipper_reached_start.connect(func():
				for ball: Balls in balls_in_flipper:
					if ball:
						ball.linear_velocity = Vector2.ZERO
				)
				
	return manipulate_to


func get_area() -> Area2D:
	return _area


func _move() -> void:
	position = _original_pos + t * ((_original_pos + move_to) - _original_pos)


func _process(delta: float) -> void:
	interpolate_t(delta)
	_move()


func _on_flipper_A_touched(_is_held: bool) -> void:
	pass


func _on_flipper_B_touched(_is_held: bool) -> void:
	pass


func _update_balls_in_flipper() -> void:
	balls_in_flipper = [rabbitball_in_flipper, bunnyball_in_flipper]
