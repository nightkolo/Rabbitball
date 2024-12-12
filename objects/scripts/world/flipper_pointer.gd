## Cannot be used as a standalone Class in the Tree;[br]
## Use world object/instance: [url]res://objects/world/flipper_pointer.tscn[/url][br][br]
## Must be a child of [Flipper].
class_name FlipperPointer
extends Node2D
# TODO: Learn @tool and error handling

@export var a_rest: Texture2D = preload("res://assets/objects/flipper-pointer-a-01.png")
@export var a_held: Texture2D = preload("res://assets/objects/flipper-pointer-a-02.png")

@export var b_rest: Texture2D = preload("res://assets/objects/flipper-pointer-b-01.png")
@export var b_held: Texture2D = preload("res://assets/objects/flipper-pointer-b-02.png")

@onready var flipper: Flipper = get_parent()

@onready var rest: Sprite2D = $Rest
@onready var held: Sprite2D = $Held




var held_scale: Vector2
var held_rot: float

var held_scale_to: Vector2 = Vector2(1.35, 1.35)
var held_rot_to: float = deg_to_rad(135.0)

func _ready() -> void:
	held_scale = held.scale
	held_rot = held.rotation
	
	await get_tree().create_timer(0.1).timeout
	match flipper.get_flipper_type():
		RuntimeMgr.FlipperType.A:
			rest.texture = a_rest
			held.texture = a_held
			
		RuntimeMgr.FlipperType.B:
			rest.texture = b_rest
			held.texture = b_held
			
		RuntimeMgr.FlipperType.INHERIT:
			print("is inherit")


func _process(_delta: float) -> void:
	held.scale = held_scale + flipper.t * ((held_scale + held_scale_to) - held_scale)
	held.rotation = held_rot + flipper.t * ((held_rot + held_rot_to) - held_rot)
