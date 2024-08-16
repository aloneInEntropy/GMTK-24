class_name World0 extends Node2D

@onready var player := $Player
@onready var enemies := $Enemies
@onready var bullet_parent := $Bullets
@onready var lbl := $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lbl.text = str(player.bullet_count)
	

func add_bullet(_direction : Vector2, _position : Vector2, _speed : float):
	var bullet := GM.create_bullet(_direction, _position, _speed)
	bullet_parent.add_child(bullet)