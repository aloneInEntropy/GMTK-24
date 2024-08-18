class_name Transition extends ColorRect

@onready var anim := $AnimationPlayer

func play_circle_in() -> AnimationPlayer:
	anim.play("circle_in")
	return anim

func play_circle_out() -> AnimationPlayer:
	anim.play("circle_out")
	return anim