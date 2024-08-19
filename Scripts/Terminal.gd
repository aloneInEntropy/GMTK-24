class_name Terminal extends Area2D

@onready var world := get_parent()

@export var bridge_size := Vector2i()
@export var bridge_position := Vector2i()


## Go to the specified scene
func use():
	world.descend_layer2(bridge_size, bridge_position)

