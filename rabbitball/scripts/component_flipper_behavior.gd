## Component for changing/customizing a [Flipper]'s behavior.
## Experimental at the moment, but has some (very) cabbled-together use-cases.
## @experimental
@tool
class_name FlipperBehaviorComponent
extends Node

@export var flipper_form: RuntimeMgr.FlipperForm
@export var turn_off_colli_at_end: bool = false
@export var remove_on_next_cabinet: bool = false
#@export var remove_onscreen_count_on_removal: bool = false ## @experimental
@export var assign_flipper_color_to: Array[Node2D]
@export var self_modulate_color: bool = false

@onready var flipper: Flipper = get_parent() as Flipper

var flipper_colli: CollisionPolygon2D
var area: Area2D

var _parent: Node


func _get_configuration_warnings() -> PackedStringArray:
	if _parent is not Flipper:
		return ["This node must be a child of Flipper."]
	else:
		return []


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_parent = get_parent()
		update_configuration_warnings()


func _ready() -> void:
	if (flipper is Flipper && flipper != null):
		await flipper.ready
		
		flipper_colli = flipper.get_node_or_null("CollisionPolygon2D")
		
		if flipper_form == RuntimeMgr.FlipperForm.MOVER:
			area = (flipper as FlipperMover).get_area() # returns Area2D or null
			
			#if remove_onscreen_count_on_removal:
				#(flipper as FlipperMover).count_onscreen = false
			
			var remove_on_next_cab := remove_on_next_cabinet && area
			
			if remove_on_next_cab:
				area.body_entered.connect(func(body: Node2D):
					if body is Rabbitball:
						await UIMgr.cabinet_completed
						nuke_the_flipper()
					)
					
		elif flipper_form == RuntimeMgr.FlipperForm.ROTATOR:
			pass
			
		elif flipper_form == RuntimeMgr.FlipperForm.BLOCK:
			pass
			
		elif flipper_form == RuntimeMgr.FlipperForm.WIDE:
			if !assign_flipper_color_to.is_empty():
				for object: Node2D in assign_flipper_color_to:
					if self_modulate_color:
						object.self_modulate = flipper.get_flipper_color()
					else:
						object.modulate = flipper.get_flipper_color()
		
		flipper.flipper_reached_end.connect(func():
			if turn_off_colli_at_end:
				if flipper_colli:
					flipper_colli.set_deferred("disabled", true)
			)
			
		flipper.flipper_reached_start.connect(func():
			pass
			)
			
		flipper.flipper_left_end.connect(func():
			if turn_off_colli_at_end:
				if flipper_colli:
					flipper_colli.set_deferred("disabled", false)
			)
			
		flipper.flipper_left_start.connect(func():
			pass
			)

	else:
		push_error(str(self) + " is not a child of Flipper.")


## Hardcore.
func nuke_the_flipper() -> void:
	flipper.queue_free()
