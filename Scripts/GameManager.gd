extends Node

## Bullet scene object
var _bullet_scene = preload("res://Scenes/Bullet.tscn")
## Sticky block scene object
var sticky_scene := preload("res://Scenes/Sticky.tscn")

var player_bullets : int
var player_health : int

func create_bullet(_direction : Vector2, _position : Vector2, _speed : float) -> Bullet:
    var new_bullet : Bullet = _bullet_scene.instantiate()
    new_bullet.setup(_direction, _position, _speed)
    return new_bullet
