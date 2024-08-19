class_name Terminal extends Area2D

@onready var world := get_parent()

@export var bridge_size := Vector2i()
@export var bridge_position := Vector2i()

var bridge : BridgeStruct

## Go to the specified scene
func use():
	SB.using_terminal.emit(bridge_size, bridge_position, self)

