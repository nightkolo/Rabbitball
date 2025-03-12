## @deprecated: A hard lesson to remind myself not to spend too much time on an ambitious feature with a large system that spans over 4 scripts with lines and lines of code, only for it to be completely scrapped, I'm pissed.
class_name Infopoint
extends Marker2D

enum InfoMode {TUTORIAL = 0, DIALOGUE = 1}

@export var area_to_open: Area2D
@export var display_info: InfoMode = InfoMode.TUTORIAL
@export_multiline var tutorial_text: String
@export_multiline var dialog_text_lines: Array[String]
@export_group("Modify")
@export var area_to_close: Area2D
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER

var is_activate: bool = false
var is_bubble_shown: bool = false:
	get:
		return is_bubble_shown
	set(val):
		if display_info == 1:
			if val:
				anim_idle()
			elif _tween_click_me:
				_tween_click_me.kill()
		is_bubble_shown = val

var _demo_lines: Array[String] = [
	"Next up,
	Arcade 2 is on the way!",
	"You need a bit of rest...",
	"In the meantime, let's see if this dialog box integration is well and working!",
	"Anyhoooooo, goodnight.",
	"Byebye!!
	-Kolo"
]
var _arrow_sprite: Sprite2D
var _arrow: Node2D
var _anim: AnimationPlayer
var _tween_click_me: Tween
var _tween_click: Tween


func _ready() -> void:
	_anim = get_node_or_null("Anim")
	_arrow = get_node_or_null("Arrow")
	_arrow_sprite = get_node_or_null("Arrow/Sprite2D")
	
	RuntimeMgr.info_bubble_entered.connect(func(val: bool):
		is_bubble_shown = val
		)
	if display_info == InfoMode.DIALOGUE:
		RuntimeMgr.info_bubble_next_line_shown.connect(func():
			anim_click()
			)
	if area_to_open:
		var area := _setup_area(area_to_open)
		
		area.body_entered.connect(func(body: Node2D):
			if body is Rabbitball:
				open_info_text(display_info)
			)
	else:
		push_warning("area_to_open not assigned")
		
	if area_to_close:
		var area := _setup_area(area_to_close)

		area.body_entered.connect(func(body: Node2D):
			if body is Rabbitball:
				close_info_text()
			)


func open_info_text(of_mode: InfoMode) -> void:
	is_activate = true
	RuntimeMgr.current_activate_infopoint = self
	
	match of_mode:
		
		InfoMode.TUTORIAL:
			RuntimeMgr.open_tutorial(global_position, tutorial_text, text_alignment)
	
		InfoMode.DIALOGUE:
			RuntimeMgr.open_dialog(global_position, dialog_text_lines, text_alignment)


func close_info_text() -> void:
	RuntimeMgr.close_info_bubble()


func _setup_area(area: Area2D) -> Area2D:
	area.monitorable = false
	area.collision_mask = 32
	area.collision_layer = 0
	
	if area is Switch:
		(area as Switch).act_as_a_tutorial_bubble_spawn_area = true
		
	return area


func anim_click() -> void:
	if (is_activate && _arrow_sprite && _arrow && _anim): # Too much?
		if _tween_click_me:
			_tween_click_me.kill()
			_arrow.scale = Vector2.ONE
		
		_arrow_sprite.scale.y = 0.3
		_arrow_sprite.scale.x = 0.6
		_anim.play("click", -1, 0.65)
		
		if _tween_click:
			_tween_click.kill()
		_tween_click = create_tween().set_parallel(true)
		_tween_click.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		_tween_click.tween_property(_arrow_sprite,"scale",Vector2.ONE/2,0.4)
		await _tween_click.finished
		if RuntimeMgr.is_info_bubble_active:
			anim_idle()


func anim_idle() -> void:
	if (is_activate && _arrow):
		if _tween_click_me:
			_tween_click_me.kill()
		_tween_click_me = create_tween().set_loops()
		_tween_click_me.set_ease(Tween.EASE_OUT)
		_tween_click_me.tween_property(_arrow,"scale",Vector2(1.1,0.8),0.1).set_delay(1.0)
		_tween_click_me.tween_property(_arrow,"scale",Vector2.ONE,0.1)
		_tween_click_me.tween_property(_arrow,"scale",Vector2(1.1,0.8),0.1)
		_tween_click_me.tween_property(_arrow,"scale",Vector2.ONE,0.3).set_trans(Tween.TRANS_BACK)
