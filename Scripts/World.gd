class_name World0 extends Node2D

@onready var player := $Player
@onready var player_rt : RemoteTransform2D = $Player/RemoteTransform2D
@onready var limit_tl : Marker2D = $Limits/MarkerTL
@onready var limit_br : Marker2D = $Limits/MarkerBR
@onready var enemies := $Enemies
@onready var bullet_parent := $Bullets
@onready var anim := $AnimationPlayer
@onready var gui : GUI = $GUI
@onready var camera : Camera2D = $Camera2D

@export var player_default_position : Vector2

# # Called when the node enters the scene tree for the first time.
# func _ready():
# 	gui.visible = true
# 	if get_tree().paused:
# 		get_tree().paused = false
# 		player.position = AM.player0_pos
# 	else:
# 		player.position = player_default_position
# 	set_camera_limits()
# 	AM.crown_scene = name
# 	play_zoom_out()
# 	player.connect("died", descend_layer)


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	gui.lbl_a.text = str(player.bullet_count)
# 	gui.lbl_b.text = str(player.health)
	
# func add_bullet(_direction : Vector2, _position : Vector2, _speed : float):
# 	var bullet := GM.create_bullet(_direction, _position, _speed)
# 	bullet_parent.add_child(bullet)

# func play_zoom_in():
# 	set_camera_limits(false)
# 	anim.play("zoom_in_player")
# 	return gui.transition_into()

# func play_zoom_out():
# 	set_camera_limits(false)
# 	anim.play("zoom_out_player")
# 	return gui.transition_out()

# func descend_layer():
# 	get_tree().paused = true
# 	AM.player0_pos = player.global_position
# 	AM.descend_layer()
# 	await play_zoom_in().animation_finished
# 	get_tree().change_scene_to_file("res://Scenes/" + AM.ring_scene + ".tscn")

# func ascend_layer():
# 	get_tree().paused = true
# 	AM.ascend_layer()

# func set_camera_limits(disable : bool = false):
# 	camera.limit_right = 1000000 if disable else int(limit_br.position.x) 
# 	camera.limit_bottom = 1000000 if disable else int(limit_br.position.y) 
# 	camera.limit_top = -1000000 if disable else int(limit_tl.position.y) 
# 	camera.limit_left = -1000000 if disable else int(limit_tl.position.x)
# 	camera.drag_horizontal_enabled = !disable
# 	camera.drag_vertical_enabled = !disable
# 	camera.position_smoothing_enabled = !disable
