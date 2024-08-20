class_name World2 extends Node2D

@onready var player := $Player2
@onready var anim := $AnimationPlayer
@onready var gui : GUI = $GUI
@onready var camera : Camera2D = $Camera2D
@onready var stickies := $Stickies
@onready var tilemap := $TileMap
@onready var rng := RandomNumberGenerator.new()

var bridge : BridgeStruct
var orig_block_count := AM.block_count
var BG_LAYER := 0
var FG_LAYER := 1
var TILE_SIZE := 18

func _ready():
	gui.visible = true
	gui.gem_tooltip.visible = true
	gui.gc.visible = false
	get_tree().paused = false
	play_zoom_out()
	bridge = AM.active_bridge_struct
	SB.bridge_submitted.connect(handle_bridge_submitted)
	SB.bridge_reset.connect(handle_bridge_reset)
	generate_random_stickies()

func generate_random_stickies():
	var mid = Vector2i(AM.active_bridge_struct.width, AM.active_bridge_struct.height)/2
	for w in range(AM.active_bridge_struct.width):
		for h in range(AM.active_bridge_struct.height):
			tilemap.set_cell(FG_LAYER, Vector2i(w, h) - mid, 0, Vector2i(3, 3))

	for s in AM.active_bridge_struct.bridge_vectors:
		var sticky : Sticky = GM.sticky_scene.instantiate()
		player.add_child(sticky)
		sticky.position = s * TILE_SIZE # set position AFTER adding to scene tree to keep position relative

	var rand_pos : Array = AM.active_bridge_struct.bridge_vectors.duplicate()
	rand_pos.append(Vector2.ZERO)
	var i = 0
	var sz = AM.block_count - AM.active_bridge_struct.bridge_vectors.size()
	var sz_l = sz/2.0 as int
	var sz_r = sz - sz_l
	var max_repetition := 10000
	var max_repetition_i := 0
	while i < sz_l:
		var p := Vector2(rng.randi_range(-13, -3), rng.randi_range(-7, 6)) * TILE_SIZE
		var nots = generate_surrounding(p, TILE_SIZE)
		var flag = rand_pos.any(func(x):
			return nots.has(x)
		)

		if !flag:
			rand_pos.append(p)
			var sticky : Sticky = GM.sticky_scene.instantiate()
			sticky.setup(p)
			stickies.add_child(sticky)
			i += 1
		max_repetition_i += 1
		if max_repetition_i >= max_repetition:
			push_error("TOO MANY REPETITIONS!!!")

	print("GEN REPS L: " + str(max_repetition_i))
	i = 0
	max_repetition_i = 0
	while i < sz_r:
		var p := Vector2(rng.randi_range(3, 13), rng.randi_range(-7, 6)) * TILE_SIZE
		var nots = generate_surrounding(p, TILE_SIZE)
		var flag = rand_pos.any(func(x):
			return nots.has(x)
		)
		if !flag:
			rand_pos.append(p)
			var sticky : Sticky = GM.sticky_scene.instantiate()
			sticky.setup(p)
			stickies.add_child(sticky)
			i += 1
		max_repetition_i += 1
		if max_repetition_i >= max_repetition:
			push_error("TOO MANY REPETITIONS!!!")
	print("GEN REPS R: " + str(max_repetition_i))

func generate_surrounding(p : Vector2, d: int = 1) -> Array:
	return [
		Vector2(p.x+d, p.y+d),
		Vector2(p.x+d, p.y-d),
		Vector2(p.x+d, p.y),
		Vector2(p.x-d, p.y+d),
		Vector2(p.x-d, p.y-d),
		Vector2(p.x-d, p.y),
		Vector2(p.x, p.y+d),
		Vector2(p.x, p.y-d),
		p
	]

func play_zoom_in():
	anim.play("zoom_in_player")
	return gui.transition_into()

func play_zoom_out():
	anim.play("zoom_out_player")
	return gui.transition_out()

func ascend_layer():
	AM.terminals[AM.active_terminal] = AM.active_bridge_struct
	get_tree().paused = true
	AM.ascend_layer()
	await play_zoom_in().animation_finished
	get_tree().change_scene_to_file("res://Scenes/" + AM.crown_scene + ".tscn")

func handle_player_solved():
	print("SOLVED")

func handle_bridge_submitted(vs: PackedVector2Array):
	AM.update_bridge(vs)
	ascend_layer()

func handle_bridge_reset(used_tiles: int):
	for i in range(stickies.get_children().size() - 1, -1, -1):
		var c = stickies.get_children()[i]
		stickies.remove_child(c)
		c.queue_free()
	AM.reset_active_terminal(used_tiles)
	player.free()
	player = GM.player_gem_scene.instantiate()
	add_child(player)
	generate_random_stickies()
