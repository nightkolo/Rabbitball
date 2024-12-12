extends Rabbitball


func _ready() -> void:
	speed = 520.0
	
	self_assign_to_nodes = false
	no_limit = true
	gravity_scale = 0.0


func _move(delta: float) -> void:
	var input_direction: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	if input_direction != Vector2.ZERO:
		position += input_direction * speed * delta
	else:
		position += Vector2.ZERO


func _physics_process(delta: float) -> void:
	_move(delta)
