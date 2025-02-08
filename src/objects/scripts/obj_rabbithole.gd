## [b]Note:[/b] Only works for [Rabbitball].
class_name Rabbithole
extends Area2D

signal rabbitball_went_through_rabbithole() ## @deprecated

enum RabbitholeType {IN = 0, OUT = 1, INSTANT_TELEPORT = 2}

@export var rabbitball: PackedScene = preload("res://objects/objects/rabbitball.tscn")
@export var going: RabbitholeType = RabbitholeType.INSTANT_TELEPORT
# TODO: rewrite to `@export var teleport_to: Rabbithole` for simplicity's sake.
@export var teleport_to: Node2D
@export var force_send: bool = false
@export_group("Assets")
@export var asset_in: Texture2D = preload("res://assets/objects/rabbithole-arrow-01.png")
@export var asset_out: Texture2D = preload("res://assets/objects/rabbithole-arrow-02.png")

var _sprite_rabbithole: Sprite2D
var _sprite_arrow: Sprite2D
var _audio_in: AudioStreamPlayer
var _audio_out: AudioStreamPlayer

var _tween: Tween
var _game_world: World ## @deprecated


func _ready() -> void:
	collision_layer = 0
	collision_mask = 32
	
	_sprite_rabbithole = get_node_or_null("Sprite2D")
	_sprite_arrow = get_node_or_null("Arrow")
	_audio_in = get_node_or_null("Audio/In")
	_audio_out = get_node_or_null("Audio/Out")
	
	setup_arrow_sprite(going)
	
	body_entered.connect(func(body: Node2D):
		var can_teleport_ball := teleport_to && body is Rabbitball
		
		if can_teleport_ball:
			var rb: Rabbitball = rabbitball.instantiate()
			
			match going:
				
				RabbitholeType.IN:
					play_going_in_sound()
					await (body as Rabbitball).anim_went_through_rabbithole(true)
					
					if !force_send:
						rb.position = teleport_to.global_position
						rb.visible = false
						
						if RuntimeMgr.current_arcade:
							play_going_out_sound()
							RuntimeMgr.rabbitball_went_through_rabbithole.emit()
							RuntimeMgr.current_arcade.add_child.call_deferred(rb)
							
							await rb.ready
							rb.anim_went_out_rabbithole(true)
					else:
						rb.position = teleport_to.position
						get_parent().add_child.call_deferred(rb)
				
				RabbitholeType.OUT:
					pass
				
				RabbitholeType.INSTANT_TELEPORT:
					(body as Rabbitball).queue_free()
					
					if !force_send:
						rb.position = teleport_to.global_position
						
						if RuntimeMgr.current_arcade:
							RuntimeMgr.rabbitball_went_through_rabbithole.emit()
							RuntimeMgr.current_arcade.add_child.call_deferred(rb)
					else:
						rb.position = teleport_to.position
						get_parent().add_child.call_deferred(rb)
							
		elif teleport_to == null && going == RabbitholeType.IN:
			push_warning("teleport_to not assigned.")
		)


func setup_arrow_sprite(p_going: RabbitholeType) -> void:
	if _sprite_arrow:
		match p_going:
			
			RabbitholeType.IN:
				_sprite_arrow.texture = asset_in
				
			RabbitholeType.OUT:
				_sprite_arrow.texture = asset_out
				
			RabbitholeType.INSTANT_TELEPORT:
				_sprite_arrow.texture = asset_in
		_anim_arrow()


func play_going_in_sound() -> void:
	if _audio_in:
		_audio_in.play()
	

func play_going_out_sound() -> void:
	if _audio_out:
		_audio_out.play()

		
func _anim_arrow() -> void:
	var pause: float
	var dur := 0.7
	var amplitude := 12.0
	_sprite_arrow.position.y += amplitude/2.0
	if going == RabbitholeType.IN:
		pause = 0.0
	elif going == RabbitholeType.OUT:
		pause = dur
	await get_tree().create_timer(pause).timeout
	
	_tween = create_tween().set_loops()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_sprite_arrow,"position:y",-amplitude,dur).as_relative()
	_tween.tween_property(_sprite_arrow,"position:y",amplitude,dur).as_relative()


func _instant_teleport_rabbitball(old_rb: Rabbitball, new_rb: Rabbitball) -> void:
	if (new_rb && old_rb):
		old_rb.queue_free()
						
		if !force_send:
			new_rb.position = teleport_to.global_position
			
			if RuntimeMgr.current_arcade:
				RuntimeMgr.rabbitball_went_through_rabbithole.emit()
				RuntimeMgr.current_arcade.add_child.call_deferred(new_rb)
		else:
			new_rb.position = teleport_to.position
			get_parent().add_child.call_deferred(new_rb)
	else:
		if new_rb == null:
			push_warning(str(new_rb) + " is null.")
			
		if old_rb == null:
			push_warning(str(old_rb) + " is null.")
