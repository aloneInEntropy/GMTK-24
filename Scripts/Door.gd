class_name Door extends Area2D

@export var destination : String = "wld"
@onready var world := get_parent()


## Go to the specified scene
func use():
	await world.play_zoom_in().animation_finished
	GM.go_to_level(get_tree(), destination)
