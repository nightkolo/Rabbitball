## Level code.
class_name Cabinet
extends Node2D

@export var write_to_spawn_info: bool = true
@export var level_name: StringName
@export var cabinet_id: int
@export var level_id: int
@export_group("Modify")
@export var reset_player_input_on_enter: bool = false

var _spawnpoint: Spawnpoint
var _endpoint: Endpoint
var _are_we_spawning_here: bool


func _ready() -> void:
	self.add_to_group("Cabinet")
	
	_spawnpoint = get_node_or_null("Spawnpoint")
	_endpoint = get_node_or_null("Endpoint")
	
	if _spawnpoint && reset_player_input_on_enter:
		_spawnpoint.rabbitball_entered.connect(func():
			PlayerInput.release_all_input()
			)
	if _endpoint:
		_endpoint.the_mighty_rabbitball_has_succeeded.connect(func():
			UIMgr.cabinet_completed.emit(cabinet_id)
			)
	
	var write := _spawnpoint && write_to_spawn_info
	
	if write:
		_spawnpoint.level_name = level_name
		_spawnpoint.cabinet_id = cabinet_id
		_spawnpoint.level_id = level_id
