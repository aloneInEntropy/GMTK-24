class_name Level extends Node2D

@onready var player := $Player
@onready var player_rt: RemoteTransform2D = $Player/RemoteTransform2D
@onready var limit_tl: Marker2D = $Limits/MarkerTL
@onready var limit_br: Marker2D = $Limits/MarkerBR
@onready var enemies := $Enemies
@onready var bullets := $Bullets
@onready var anim := $AnimationPlayer
@onready var gui: GUI = $GUI
@onready var camera: Camera2D = $Camera2D
@onready var tilemap: TileMap = $TileMap
@onready var start_pos: Marker2D = $StartPos

## Flag to avoid connecting to player death twice
var _has_died := false
## Delimiter for separating terminal names from their parent world name
const _TERMINAL_NAME_DELIMITER := "||"

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.visible = true
	AM.ascending = false
	AM.descending = false
	match GM.load_reason:
		GM.LOAD_REASON.AT_TERMINAL:
			player.position = AM.player0_pos
		GM.LOAD_REASON.DEATH:
			player.position = start_pos.position
		_:
			pass
	if GM.holding_level_enemies:
		GM.holding_level_enemies = false
		for i in range(enemies.get_children().size() - 1, -1, -1):
			var e = enemies.get_children()[i]
			enemies.remove_child(e)
			e.queue_free()
		for e in GM.level_enemies:
			var enemy = GM.enemy_scene.instantiate()
			enemies.add_child(enemy)
			enemy.position = e

	gui.gem_tooltip.visible = false
	get_tree().paused = false
	AM.crown_scene = name
	make_bridges()
	set_camera_limits()
	play_zoom_out()
	player.connect("died", handle_player_death)
	SB.using_terminal.connect(descend_layer)
	SB.show_bridge.connect(handle_show_bridge)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	gui.bullets_lbl.text = "[center]" + str(player.bullet_count)
	gui.health_lbl.text = "[center]" + str(player.health)
	gui.blocks_lbl.text = "[center]" + str(AM.block_count)
	
func add_bullet(_direction: Vector2, _position: Vector2, _speed: float):
	var bullet := GM.create_bullet(_direction, _position, _speed)
	bullets.add_child(bullet)

func play_zoom_in():
	set_camera_limits(false)
	anim.play("zoom_in_player")
	return gui.transition_into()

func play_zoom_out():
	set_camera_limits(false)
	anim.play("zoom_out_player")
	return gui.transition_out()

func descend_layer(v: Vector2i, p: Vector2, t: Terminal):
	get_tree().paused = true
	GM.level_enemies = enemies.get_children().reduce(func(accum: Array, child: Node):
		accum.push_back(child.position)
		return accum, [])
	GM.holding_level_enemies = true
	AM.active_terminal = name + _TERMINAL_NAME_DELIMITER + t.name
	AM.player0_pos = player.global_position
	AM.descend_layer(v.x, v.y, p)
	await play_zoom_in().animation_finished
	get_tree().change_scene_to_packed(GM.bridge_builder_scene)

func ascend_layer():
	get_tree().paused = true
	AM.ascend_layer()

func set_camera_limits(disable: bool = false):
	camera.limit_right = 1000000 if disable else int(limit_br.position.x)
	camera.limit_bottom = 1000000 if disable else int(limit_br.position.y)
	camera.limit_top = -1000000 if disable else int(limit_tl.position.y)
	camera.limit_left = -1000000 if disable else int(limit_tl.position.x)
	camera.drag_horizontal_enabled = !disable
	camera.drag_vertical_enabled = !disable
	camera.position_smoothing_enabled = !disable

## Builds the player's bridge in the world
func make_bridges():
	AM.awaiting_bridge = false
	if AM.lvl_terminals[name]:
		var terminals = AM.lvl_terminals[name] as Dictionary
		for t: String in terminals:
			var term = get_node(t.split(_TERMINAL_NAME_DELIMITER)[-1]) as Terminal
			var pos = term.bridge_position
			for v in terminals[t].bridge_vectors:
				tilemap.set_cell(GM.TILEMAP_LAYER.WALL, pos / 18 + Vector2i(v), 0, GM.PLAYER_BLOCK_TILE_COORD)

func handle_player_death():
	if !AM.descending:
		if !_has_died:
			_has_died = true
			GM.load_reason = GM.LOAD_REASON.DEATH
			AM.block_count = 0
			# Clear all bullets to avoid updating the null reference to the player
			for i in range(bullets.get_children().size() - 1, -1, -1):
				var b = bullets.get_children()[i]
				bullets.remove_child(b)
				b.queue_free()

			get_tree().paused = true
			await play_zoom_in().animation_finished
			get_tree().reload_current_scene()

func handle_show_bridge(_show: bool, cam_pos: Vector2):
	player_rt.global_position = cam_pos if _show else player.position


func handle_level_restart():
	handle_player_death()
