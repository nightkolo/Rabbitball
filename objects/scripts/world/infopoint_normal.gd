## A less rigid and abstract version of the deprecated info bubble system and [Infopoint].[br]
## Used for the short cutscene in the intro.
extends Marker2D

signal info_bubble_entered(is_on: bool)

@export var area_to_open: Area2D
@export_multiline var bubble_text: String
@export_group("Modify")
@export var area_to_close: Area2D
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER

#var is_activate: bool = false
var is_bubble_shown: bool = false:
	get:
		return is_bubble_shown
	set(val):
		is_bubble_shown = val
var current_info_bubble: InfoBubble
var current_bubble: Bubble

var _info_bubble: PackedScene = preload("res://objects/world/info_bubble_text.tscn")
var _bubble: PackedScene = preload("res://objects/world/info_bubble.tscn")
var _bubble_pos: Vector2


func _ready() -> void:
	#open_bubble(global_position, bubble_text, text_alignment)
	
	info_bubble_entered.connect(func(val: bool):
		is_bubble_shown = val
		)
	if area_to_open:
		var area := _setup_area(area_to_open)
		
		area.body_entered.connect(func(body: Node2D):
			if body is Rabbitball && !is_bubble_shown:
				open_bubble(global_position, bubble_text, text_alignment)
			)
	else:
		push_warning("area_to_open not assigned")
		
	if area_to_close:
		var area := _setup_area(area_to_close)

		area.body_entered.connect(func(body: Node2D):
			if body is Rabbitball && is_bubble_shown:
				is_bubble_shown = false
				#close_info_text()
			)


func open_bubble(pos: Vector2 = global_position, text: String = bubble_text, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	_bubble_pos = pos
	bubble_text = text
	text_alignment = align
	_show_bubble()
	
	info_bubble_entered.emit(true)


func _show_bubble():
	current_bubble = _bubble.instantiate()
	current_bubble.position = _bubble_pos
	RuntimeMgr.current_arcade.add_child(current_bubble)
	
	current_info_bubble = _info_bubble.instantiate()
	current_info_bubble.position = _bubble_pos
	RuntimeMgr.current_arcade.add_child(current_info_bubble)
	
	current_info_bubble.size_changed.connect(func(p_s: Vector2):
		current_bubble.size_to(p_s)
		)
	current_info_bubble.letter_showed.connect(func():
		current_bubble.anim_letter_show()
		)
	
	current_info_bubble.show_text(bubble_text, text_alignment)


func _setup_area(area: Area2D) -> Area2D:
	area.monitorable = false
	area.collision_mask = 32
	area.collision_layer = 0
	
	if area is Switch:
		(area as Switch).act_as_a_tutorial_bubble_spawn_area = true
		
	return area
