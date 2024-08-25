extends Control

@onready var crown: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	crown.play("goodbye")
	crown.animation_finished.connect(say_thank_you)

func say_thank_you():
	anim.play("end_anim")