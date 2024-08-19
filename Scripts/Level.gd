class_name Level extends Node2D

@onready var player := $Player
@onready var player_rt : RemoteTransform2D = $Player/RemoteTransform2D
@onready var limit_tl : Marker2D = $Limits/MarkerTL
@onready var limit_br : Marker2D = $Limits/MarkerBR
@onready var enemies := $Enemies
@onready var bullet_parent := $Bullets
@onready var anim := $AnimationPlayer
@onready var gui : GUI = $GUI
@onready var camera : Camera2D = $Camera2D
@onready var bridge_cams := $BridgeCams
@onready var tilemap : TileMap = $TileMap

@export var player_default_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.visible = true
	if get_tree().paused:
		get_tree().paused = false
		player.position = AM.player0_pos
	else:
		player.position = player_default_position
	AM.crown_scene = name
	make_bridges()
	set_camera_limits()
	play_zoom_out()
	player.connect("died", handle_player_death)
	SB.using_terminal.connect(descend_layer)
	SB.show_bridge.connect(handle_show_bridge)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	gui.lbl_a.text = str(player.bullet_count)
	gui.lbl_b.text = str(player.health)
	
func add_bullet(_direction : Vector2, _position : Vector2, _speed : float):
	var bullet := GM.create_bullet(_direction, _position, _speed)
	bullet_parent.add_child(bullet)

func play_zoom_in():
	set_camera_limits(false)
	anim.play("zoom_in_player")
	return gui.transition_into()

func play_zoom_out():
	set_camera_limits(false)
	anim.play("zoom_out_player")
	return gui.transition_out()

func handle_player_death():
	get_tree().paused = true
	AM.player0_pos = player.global_position
	await play_zoom_in().animation_finished
	get_tree().reload_current_scene()

func handle_show_bridge(_show: bool, cam_pos: Vector2):
	# bridge_cams.find_child(cam_name).enabled = _show
	# camera.enabled = !_show
	player_rt.global_position = cam_pos if _show else player.position

func descend_layer(v : Vector2i, p: Vector2, t: Terminal):
	AM.active_terminal = t.name
	get_tree().paused = true
	AM.player0_pos = player.global_position
	AM.descend_layer2(v.x, v.y, p)
	await play_zoom_in().animation_finished
	get_tree().change_scene_to_file("res://Scenes/" + AM.ring_scene + ".tscn")

func ascend_layer():
	get_tree().paused = true
	AM.ascend_layer()

func set_camera_limits(disable : bool = false):
	for cam : Camera2D in bridge_cams.get_children():
		cam.limit_right = 1000000 if disable else int(limit_br.position.x)
		cam.limit_bottom = 1000000 if disable else int(limit_br.position.y)
		cam.limit_top = -1000000 if disable else int(limit_tl.position.y) 
		cam.limit_left = -1000000 if disable else int(limit_tl.position.x)
		cam.drag_horizontal_enabled = !disable
		cam.drag_vertical_enabled = !disable
		cam.position_smoothing_enabled = !disable

func make_bridges():
	## todo: fix incorrect block counts
	AM.awaiting_bridge = false
	if AM.lvl_terminals[name]:
		var terminals = AM.lvl_terminals[name] as Dictionary
		for t : String in terminals:
			var term = get_node(t) as Terminal
			var pos = term.bridge_position
			for v in terminals[t].bridge_vectors:
				tilemap.set_cell(2, pos/18 + Vector2i(v), 0, Vector2i(2, 1))
