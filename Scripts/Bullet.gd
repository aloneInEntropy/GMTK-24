class_name Bullet extends Area2D

var speed: float
var dir: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += dir * speed * delta

func setup(_dir: Vector2, _pos: Vector2, _speed: float):
	speed = _speed
	dir = _dir
	position = _pos + Vector2(0, 3)

func die():
	print(name + " WAS DESTROYED")
	queue_free()

func _on_body_entered(body: Node2D):
	if !(body is Player0):
		queue_free()

func _on_death_timer_timeout():
	queue_free()
