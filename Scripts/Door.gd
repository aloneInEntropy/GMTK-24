class_name Door extends Area2D

@export var destination : String = "wld"
@onready var world := get_parent()


## Go to the specified scene
func use():
	await world.play_zoom_in().animation_finished
	get_tree().change_scene_to_file("res://Scenes/" + destination + ".tscn")
