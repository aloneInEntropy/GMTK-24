class_name World2 extends Node2D

@onready var player := $Player2
@onready var anim := $AnimationPlayer
@onready var gui : GUI = $GUI
@onready var camera : Camera2D = $Camera2D
@onready var stickies := $Stickies
@onready var tilemap := $TileMap
# @onready var player_follows := $PlayerFollows

var bridge : BridgeStruct
var BG_LAYER := 0
var FG_LAYER := 1

func _ready():
	gui.visible = true
	get_tree().paused = false
	play_zoom_out()
	player.connect("died", descend_layer)
	bridge = AM.active_bridge_struct
	SB.bridge_submitted.connect(handle_bridge_submitted)
	generate_random_stickies()

func generate_random_stickies():
	var mid = Vector2i(AM.active_bridge_struct.width, AM.active_bridge_struct.height)/2
	for w in range(AM.active_bridge_struct.width):
		for h in range(AM.active_bridge_struct.height):
			tilemap.set_cell(FG_LAYER, Vector2i(w, h) - mid, 0, Vector2i(3, 3))

	var rand_pos := []
	var i = 0
	var sz = AM.block_count
	var sz_l = sz/2.0 as int
	var sz_r = sz - sz_l
	while i < sz_l:
		var p := Vector2(randi_range(-13, -2), randi_range(-7, 6)) * 18
		var nots = generate_surrounding(p, 18)
		var flag = rand_pos.any(func(x):
			return nots.has(x)
		)
		if !flag:
			rand_pos.append(p)
			var sticky : Sticky = GM.sticky_scene.instantiate()
			sticky.setup(p)
			stickies.add_child(sticky)
			i += 1
		
	i = 0
	while i < sz_r:
		var p := Vector2(randi_range(2, 13), randi_range(-7, 6)) * 18
		var nots = generate_surrounding(p, 18)
		var flag = rand_pos.any(func(x):
			return nots.has(x)
		)
		if !flag:
			rand_pos.append(p)
			var sticky : Sticky = GM.sticky_scene.instantiate()
			sticky.setup(p)
			stickies.add_child(sticky)
			i += 1

func generate_surrounding(p : Vector2, d: int = 1) -> Array:
	return [
		Vector2(p.x+d, p.y+d),
		Vector2(p.x+d, p.y-d),
		Vector2(p.x+d, p.y),
		Vector2(p.x-d, p.y+d),
		Vector2(p.x-d, p.y-d),
		Vector2(p.x-d, p.y),
		Vector2(p.x, p.y+d),
		Vector2(p.x, p.y-d)
	]

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

func handle_player_solved():
	print("SOLVED")

func handle_bridge_submitted(vs: PackedVector2Array):
	AM.active_bridge_struct.create_bridge(vs)
	ascend_layer()
