extends Node

## The reason the level was (re)loaded
enum LOAD_REASON {DEATH, AT_TERMINAL}

## TileMap layers for each level's TileMap
enum TILEMAP_LAYER{FAR_BG, CLOSE_BG, WALL, FG_LAYER}

var PLAYER_BLOCK_TILE := Vector2i(3, 0)
var TILE_SIZE := 18

## Bullet scene object
var _bullet_scene = preload("res://Scenes/Bullet.tscn")
## Sticky block scene object
var sticky_scene := preload("res://Scenes/Sticky.tscn")
## Enemy scene object
var enemy_scene := preload("res://Scenes/Enemy.tscn")
## Player (CROWN) scene object
var player_crown_scene := preload("res://Scenes/Player_0.tscn")
## Player (GEM) scene object
var player_gem_scene := preload("res://Scenes/Player_2.tscn")
## Why was the level reloaded?
var load_reason: LOAD_REASON

var holding_level_enemies: bool
var level_enemies: Array


func create_bullet(_direction: Vector2, _position: Vector2, _speed: float) -> Bullet:
    var new_bullet: Bullet = _bullet_scene.instantiate()
    new_bullet.setup(_direction, _position, _speed)
    return new_bullet

## Go to a level using its name. 
func go_to_level(s: SceneTree, nm: String):
    AM.block_count = 0
    AM.terminals = Dictionary()
    AM.ascending = false
    AM.descending = false
    load_reason = LOAD_REASON.DEATH # achieves the same thing as a level change
    s.change_scene_to_file("res://Scenes/" + nm + ".tscn")
