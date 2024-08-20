class_name GUI extends CanvasLayer

@onready var gc := $GridContainer
@onready var bullets_lbl := $GridContainer/PlayerBullets
@onready var health_lbl := $GridContainer/PlayerHealth
@onready var blocks_lbl := $GridContainer/PlayerBlocks
@onready var transition : Transition = $CircleTransition
@onready var gem_tooltip := $GEMTooltip

func transition_into():
	return transition.play_circle_in()

func transition_out():
	return transition.play_circle_out()
