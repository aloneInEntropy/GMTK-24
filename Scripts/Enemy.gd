class_name Enemy extends CharacterBody2D

@onready var world : World0 = get_parent().get_parent()
@onready var player_check : RayCast2D = $PlayerCheck
@onready var opp_player_check : RayCast2D = $OppPlayerCheck
@onready var floor_detector_l : RayCast2D= $FloorDetectorL
@onready var floor_detector_r : RayCast2D= $FloorDetectorR
@onready var shoot_timer : Timer = $ShootTimer
@onready var move_timer : Timer = $MovementTimer

const SPEED = 900.0
const ATTACK_SPEED = 6000.0
const JUMP_VELOCITY = -400.0
const BULLET_SPEED = 300.0
const DEFAULT_PLAYER_CHECK_DIRECTION := Vector2(400, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health : int = 3
var direction : int = _rand_dir()
var is_aggro : bool
var player_direction_ray : RayCast2D

func _ready():
	shoot_timer.start()
	move_timer.start()

func _process(_delta):
	if health <= 0:
		die()

func _physics_process(delta):
	is_aggro = player_check.is_colliding() or opp_player_check.is_colliding()
	if is_aggro:
		if shoot_timer.is_stopped():
			shoot_timer.start()
		if player_check.is_colliding():
			player_direction_ray = player_check
		if opp_player_check.is_colliding():
			player_direction_ray = opp_player_check
		direction = int(player_direction_ray.target_position.normalized().x)
		velocity.x = direction * ATTACK_SPEED * delta
	else:
		player_check.target_position = direction * DEFAULT_PLAYER_CHECK_DIRECTION
		opp_player_check.target_position = direction * DEFAULT_PLAYER_CHECK_DIRECTION * Vector2(-1, 0)
		velocity.x = direction * SPEED * delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func shoot():
	world.add_bullet(player_direction_ray.target_position.normalized(), position, BULLET_SPEED)

func take_damage(dmg : int = 1):
	health -= dmg
	print("{0} took damage! (Health = {1})".format([name, health]))

func die():
	print(name + " DIED")
	queue_free()


func _on_shoot_timer_timeout():
	if is_aggro:
		shoot()

func _on_movement_timer_timeout():
	if !is_aggro:
		direction = _rand_dir()

func _rand_dir() -> int:
	var rand = randi_range(0, 1)
	return 1 if rand == 0 else -1