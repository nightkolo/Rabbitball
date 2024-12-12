## @deprecated
class_name SubCabinet
extends Node2D

@export var objects_to_remove: Array[Node2D] = []
@export var platforms_to_remove: Array[Platform] = []

var _rabbithole_in: Rabbithole
var _rabbithole_out: Rabbithole


func _ready() -> void:
	_rabbithole_in = get_node_or_null("RabbitholeIn")
	_rabbithole_out = get_node_or_null("RabbitholeOut")
	
	_rabbithole_in.rabbitball_went_through_rabbithole.connect(subcabinet_entered)
	_rabbithole_out.rabbitball_went_through_rabbithole.connect(subcabinet_entered)
	


func subcabinet_entered(went_in: bool) -> void:
	for platform: Platform in platforms_to_remove:
		var colli: CollisionPolygon2D = platform.get_node_or_null("CollisionPolygon2D")
		
		if colli:
			colli.set_deferred("disabled", went_in)
