## Arcade code.
class_name World
extends Node2D

@export var arcade: int
@export var auto_spawn: bool = true
@export var spawn_at: int
@export_group("Miscellaneous")
@export var show_dev_ui: bool = false

@onready var _spawns: Array[Node] = get_tree().get_nodes_in_group("Spawn")

var _dev_ui: PackedScene = preload("res://menus/runtime/ui/misc/dev_ui.tscn")


func _ready() -> void:
	RuntimeMgr.current_arcade = self
	UIMgr.ARCADE_ID = arcade
	UIMgr.MENU_ID = UIMgr.GameMenus.RUNTIME
	
	if show_dev_ui:
		var dev_ui = _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)
		move_child(dev_ui, 0)
	
	if UIMgr.auto_spawn_rabbitball:
		if !UIMgr.hello_from_the_cabinet_select_screen:
			if auto_spawn:
				spawn_rb_into_arcade()
			else:
				spawn_rb_into_arcade(spawn_at)
		else:
			spawn_rb_into_level()


func spawn_rb_into_arcade(p_spawn_at: int = UIMgr.CABINET_ID) -> void:
	UIMgr.CABINET_ID = p_spawn_at
	#await _delay()
	
	for spawn_point: Spawnpoint in _spawns:
		if spawn_point.cabinet_id == UIMgr.CABINET_ID:
			spawn_point.spawn()
			UIMgr.cabinet_entered.emit(UIMgr.CABINET_ID)


func spawn_rb_into_level() -> void:
	#await _delay()
	for spawn_point: Spawnpoint in _spawns:
		if spawn_point.level_id == UIMgr.LEVEL_ID:
			spawn_point.spawn()
			UIMgr.level_entered.emit(UIMgr.LEVEL_ID)


func _delay() -> void:
	await get_tree().create_timer(0.2).timeout
