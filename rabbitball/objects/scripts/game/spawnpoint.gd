## Also acts as a checkpoint.
class_name Spawnpoint
extends Marker2D
# TODO: Move this information handling somewhere else. 
# Counter-TODO: maybe if it ain't broke, don't fix it?

signal has_spawned()
signal rabbitball_entered()

@export var rabbitball: PackedScene = preload("res://objects/objects/rabbitball.tscn")
@export var force_spawn: bool = false:
	set(val):
		UIMgr.auto_spawn_rabbitball = !val
		force_spawn = val

var level_name: StringName
var cabinet_id: int
var level_id: int
var has_been_activated: bool = false

var _area: Area2D
var _game_world: World


func _ready() -> void:
	add_to_group("Spawn")
	_area = get_node_or_null("Area2D")
	if get_parent().get_parent() is World:
		_game_world = (get_parent().get_parent() as World) # Trust me bro, trust me
	if _area:
		_area.collision_layer = 0
		_area.collision_mask = 32
		
		_area.body_entered.connect(func(body: Node2D):
			var entered := !has_been_activated && body is Rabbitball
			
			if entered:
				rabbitball_entered.emit()
				UIMgr.LEVEL_NAME = level_name
				UIMgr.CABINET_ID = cabinet_id
				UIMgr.LEVEL_ID = level_id
				UIMgr.current_spawnpoint = self
				UIMgr.level_info_updated.emit()
				
				has_been_activated = true
			)
	if force_spawn:
		spawn()


func spawn() -> void:
	var rb := rabbitball.instantiate()
	
	if !force_spawn:
		rb.position = self.global_position
		
		if RuntimeMgr.current_arcade:
			RuntimeMgr.current_arcade.add_child.call_deferred(rb)
			has_spawned.emit()
		
		#if cabinet_id == 0:
		if level_id == 101:
			rb.freeze = true
			await get_tree().create_timer(UIMgr.INTRO_CUTSCENE_ANIMS_WAITTIME).timeout
			rb.freeze = false
			
	else:
		rb.position = self.position
		get_parent().add_child.call_deferred(rb)
		has_spawned.emit()
