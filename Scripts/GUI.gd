class_name GUI extends CanvasLayer

@onready var gc := $GridContainer
@onready var bullets_lbl := $GridContainer/PlayerBullets
@onready var health_lbl := $GridContainer/PlayerHealth
@onready var blocks_lbl := $GridContainer/PlayerBlocks
@onready var transition : Transition = $CircleTransition
@onready var gem_tooltip := $GEMTooltip
@onready var pause_menu := $Pause

var is_paused := false

func _process(_delta):
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

func _input(event):
	if event.is_action_pressed("pause"):
		is_paused = !is_paused

func transition_into():
	return transition.play_circle_in()

func transition_out():
	return transition.play_circle_out()

		
