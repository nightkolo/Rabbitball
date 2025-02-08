class_name Endpoint
extends Area2D

signal the_mighty_rabbitball_has_succeeded()

var has_entered: bool = false

var _particles: CPUParticles2D
var _tween: Tween


func _ready() -> void:
	collision_layer = 0
	collision_mask = 32
	
	_particles = get_node_or_null("CPUParticles2D")
	
	the_mighty_rabbitball_has_succeeded.connect(func():
		if _particles && !has_entered:
			_particles.emitting = true
			_tween = create_tween()
			_tween.tween_property(_particles,"self_modulate",Color(Color.WHITE,0.0),_particles.lifetime/2.0).set_delay(_particles.lifetime/2.0)
		
		has_entered = true
		)
	
	body_entered.connect(func(body: Node2D):
		var entered := !has_entered && body is Rabbitball
		
		if entered:
			the_mighty_rabbitball_has_succeeded.emit()
		)
		
