class_name World2 extends Node2D

@onready var player := $Player2
@onready var anim := $AnimationPlayer
@onready var gui : GUI = $GUI
@onready var camera : Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	play_zoom_out()
	player.connect("died", descend_layer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_zoom_in():
	anim.play("zoom_in_player")
	return gui.transition_into()

func play_zoom_out():
	anim.play("zoom_out_player")
	return gui.transition_out()

func descend_layer():
	get_tree().paused = true
	AM.descend_layer()
	await play_zoom_in().animation_finished
	get_tree().change_scene_to_file("res://Scenes/" + AM.ring_scene + ".tscn")

func ascend_layer():
	get_tree().paused = true
	AM.ascend_layer()
	await play_zoom_in().animation_finished
	get_tree().change_scene_to_file("res://Scenes/" + AM.crown_scene + ".tscn")
