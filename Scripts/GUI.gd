class_name GUI extends CanvasLayer

@onready var lbl := $PlayerBullets
@onready var transition : Transition = $CircleTransition

func transition_into():
	return transition.play_circle_in()

func transition_out():
	return transition.play_circle_out()
