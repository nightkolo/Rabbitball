## Interface Actor Model
extends Node

signal current_cabinet_coordinates_changed(is_coord: Vector2)
signal level_info_updated()
signal rabbitball_spawned(is_rb: Rabbitball)
signal game_reset()
signal game_end()
signal camera_stop()
signal cabinet_completed(is_cab: int) ## Emitted by [signal Endpoint.the_mighty_rabbitball_has_succeeded] by [Cabinet].
signal cabinet_entered(is_cab: int) ## Emitted when [member CABINET_ID] is set.
signal level_entered(is_lvl: int) ## Emitted by [World] when entering a Arcade Cabinet (World level).
signal menu_entered(is_menu: GameMenus) ## Emitted when [member MENU_ID] is set.
signal runtime_manager_reset()

# Config
signal sounds_option_set(on: bool)
signal dynamic_camera_option_set(on: bool)

enum GameMenus {START = 0, TITLE = 1, CABINET_SELECT = 2, OPTIONS = 3, CREDITS = 4, PAUSE_MENU = 5, PAUSE_MENU_OPTIONS = 6, RUNTIME = 99}

@onready var SFX_BUS_ID: int = AudioServer.get_bus_index("SFX")

var game_current_version: String = ProjectSettings.get_setting("application/config/version")
var game_current_version_text: String = ("v" + ProjectSettings.get_setting("application/config/version")).trim_suffix(".0")

var hello_from_the_cabinet_select_screen: bool = false
var auto_spawn_rabbitball: bool = true
var current_spawnpoint: Spawnpoint
var current_cab_coord: Vector2

var ARCADE_ID: int
var LEVEL_NAME: StringName = &""
var LEVEL_ID: int = 0
var CABINET_ID: int = 1:
	get:
		return CABINET_ID
	set(value):
		if value != CABINET_ID:
			cabinet_entered.emit(value)
		CABINET_ID = value
var MENU_ID: GameMenus = GameMenus.START:
	get:
		return MENU_ID
	set(value):
		if value != MENU_ID:
			menu_entered.emit(value)
		MENU_ID = value

# Config
var controller_vibration: bool = true ## @experimental
var _game_audio_muted: bool = false:
	get:
		return _game_audio_muted
	set(value):
		AudioServer.set_bus_mute(SFX_BUS_ID, value)
		_game_audio_muted = value
		sounds_option_set.emit(value)
var _dynamic_camera_on: bool = true:
	get:
		return _dynamic_camera_on
	set(value):
		_dynamic_camera_on = value
		dynamic_camera_option_set.emit(value)

const SCREEN_SIZE = Vector2(900.0, 720.0)
const INTRO_CUTSCENE_ANIMS_WAITTIME = 1.5
const NUMBER_OF_CABINETS = 10
const NUMBER_OF_ARCADES = 2
const NUMBER_OF_LEVELS = NUMBER_OF_ARCADES * NUMBER_OF_CABINETS
const ARCADE_FILE_BEGIN = "res://menus/runtime/levels/world_"
const ARCADE_FILE_END = ".tscn"


func _ready() -> void:
	level_entered.connect(_on_level_entered)
	game_end.connect(goto_next_arcade)
	
	current_cabinet_coordinates_changed.connect(func(is_coord: Vector2):
		current_cab_coord = is_coord
		)
	
	menu_entered.connect(func(is_menu: GameMenus):
		if (is_menu != UIMgr.GameMenus.RUNTIME && is_menu != UIMgr.GameMenus.PAUSE_MENU_OPTIONS && is_menu != UIMgr.GameMenus.PAUSE_MENU):
			RuntimeMgr.self_destruct()
		)
	
	game_reset.connect(func():
		RuntimeMgr.self_destruct()
		get_tree().reload_current_scene()
		)


func goto_next_arcade() -> void:
	RuntimeMgr.self_destruct()
	CABINET_ID = 1
	
	var next_arcade_id: int = ARCADE_ID + 1
	var next_arcade_path: String = ARCADE_FILE_BEGIN + str(next_arcade_id) + ARCADE_FILE_END
	
	if next_arcade_id <= NUMBER_OF_ARCADES:
		await get_tree().create_timer(1.1).timeout
		Trans.bars_to_scene(next_arcade_path, 0.75, 0.75, 0.77)

	else:
		await get_tree().create_timer(1.5).timeout
		Trans.fade_to_scene("res://menus/menu_credits.tscn", 0.125, 1.0, 0.5)


# Config
func set_game_audio_muted(value: bool) -> void:
	_game_audio_muted = value
	
	
func set_dynamic_camera(value: bool) -> void:
	_dynamic_camera_on = value


func get_game_audio_muted_setting() -> bool:
	return _game_audio_muted
	

func get_dynamic_camera_on_setting() -> bool:
	return _dynamic_camera_on


func rad_to_vector(rad: float) -> Vector2:
	var x = cos(rad)
	var y = sin(rad)
	return Vector2(x, y)


func _on_level_entered(_is_lvl: int) -> void:
	hello_from_the_cabinet_select_screen = false
	auto_spawn_rabbitball = true
