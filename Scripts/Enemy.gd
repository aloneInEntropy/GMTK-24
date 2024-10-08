class_name Enemy extends CharacterBody2D

@onready var world := get_parent().get_parent()
@onready var player_check: RayCast2D = $PlayerCheck
@onready var opp_player_check: RayCast2D = $OppPlayerCheck
@onready var floor_detector_l: RayCast2D = $FloorDetectorL
@onready var floor_detector_r: RayCast2D = $FloorDetectorR
@onready var shoot_timer: Timer = $ShootTimer
@onready var move_timer: Timer = $MovementTimer
@onready var aggro_timer: Timer = $AggroTimer
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rng := RandomNumberGenerator.new()

const SPEED = 900.0
const ATTACK_SPEED = 6000.0
const BULLET_SPEED = 400.0
const DEFAULT_PLAYER_CHECK_DIRECTION := Vector2(400, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int = 3
var direction: int
var is_aggro: bool
var player_direction_ray: RayCast2D
var _last_player_position : Vector2

func _ready():
	direction = _rand_dir()
	shoot_timer.start()
	move_timer.start()
	anim_sprite.play("idle")

func _process(_delta):
	check_health()
	if direction == 1:
		anim_sprite.flip_h = true
	else:
		anim_sprite.flip_h = false

func _physics_process(delta):
	if player_check.is_colliding() and player_check.get_collider() is Player0:
		player_direction_ray = player_check
		var p = player_check.get_collider() as Player0
		_last_player_position = Vector2(p.position.x, 0)
		is_aggro = true
		aggro_timer.start()
	elif opp_player_check.is_colliding() and opp_player_check.get_collider() is Player0:
		player_direction_ray = opp_player_check
		var p = opp_player_check.get_collider() as Player0
		_last_player_position = Vector2(p.position.x, 0)
		is_aggro = true
		aggro_timer.start()
	
		
	# print(player_check.is_colliding() and player_check.get_collider() is Player0)
	# print(opp_player_check.is_colliding() and opp_player_check.get_collider() is Player0)
	# print(aggro_timer.time_left)
	if is_aggro:
		anim_sprite.play("aggro")
		if player_direction_ray.is_colliding():
			if shoot_timer.is_stopped():
				shoot_timer.start()
		direction = sign(_last_player_position.x - position.x)
		velocity.x = direction * ATTACK_SPEED * delta
		if int(position.x) == int(_last_player_position.x) or direction == 0:
			is_aggro = false
	else:
		anim_sprite.play("idle")
		player_check.target_position = direction * DEFAULT_PLAYER_CHECK_DIRECTION
		opp_player_check.target_position = direction * DEFAULT_PLAYER_CHECK_DIRECTION * Vector2(-1, 0)
		velocity.x = direction * SPEED * delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func shoot():
	world.add_bullet(player_direction_ray.target_position.normalized(), position, BULLET_SPEED)

func take_damage(dmg: int = 1):
	health -= dmg
	print("{0} took damage! (Health = {1})".format([name, health]))
	check_health()

func check_health():
	if health <= 0:
		die()

func die():
	print(name + " DIED")
	queue_free()

func _rand_dir() -> int:
	var rand = rng.randi_range(0, 1)
	return 1 if rand == 0 else -1


func _on_shoot_timer_timeout():
	if is_aggro:
		shoot()

func _on_movement_timer_timeout():
	if !is_aggro:
		direction = _rand_dir()

func _on_aggro_timer_timeout():
	is_aggro = false
	print("not angy")
