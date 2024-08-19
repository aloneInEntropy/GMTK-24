class_name GUI extends CanvasLayer

@onready var lbl_a := $PlayerBullets
@onready var lbl_b := $PlayerHealth
@onready var transition : Transition = $CircleTransition

func transition_into():
	return transition.play_circle_in()

func transition_out():
	return transition.play_circle_out()
