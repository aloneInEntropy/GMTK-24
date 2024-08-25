extends Control

@onready var rng := RandomNumberGenerator.new()
@onready var p_anim := $PlayerSprite
@onready var e_anim := $EnemySprite

var p_anims := ["shoot", "idle", "crouch"]
var e_anims := ["aggro", "idle"]
## Frames before randomly picking an animation to play
var p_anim_change := 150
var p_anim_change_timer := 150
var e_anim_change := 150
var e_anim_change_timer := 150
## Frames before randomly picking a direction to point in
var p_dir_change: int
var p_dir_change_timer: int
var e_dir_change: int
var e_dir_change_timer: int

var guide_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	p_anim.play("idle")
	p_dir_change = rng.randi_range(75, 250)
	p_dir_change_timer = p_dir_change
	e_dir_change = rng.randi_range(75, 250)
	e_dir_change_timer = e_dir_change


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	p_anim_change_timer = move_toward(p_anim_change_timer, -1, 1) as int
	if !p_anim.is_playing() or p_anim_change_timer == -1:
		p_anim_change_timer = p_anim_change
		p_anim.play(p_anims[rng.randi_range(0, 2)])
	e_anim_change_timer = move_toward(e_anim_change_timer, -1, 1) as int
	if !e_anim.is_playing() or e_anim_change_timer == -1:
		e_anim_change_timer = e_anim_change
		e_anim.play(e_anims[rng.randi_range(0, 1)])
	p_dir_change_timer = move_toward(p_dir_change_timer, -1, 1) as int
	if p_dir_change_timer == -1:
		p_dir_change = rng.randi_range(75, 250)
		p_dir_change_timer = p_dir_change
		p_anim.flip_h = !p_anim.flip_h
	e_dir_change_timer = move_toward(e_dir_change_timer, -1, 1) as int
	if e_dir_change_timer == -1:
		e_dir_change = rng.randi_range(75, 250)
		e_dir_change_timer = e_dir_change
		e_anim.flip_h = !e_anim.flip_h


func _on_play_button_pressed():
	if guide_shown:
		GM.go_to_level(get_tree(), "level_1")
	else:
		guide_shown = true
		$GuideBG.visible = true
