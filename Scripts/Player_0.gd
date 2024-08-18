class_name Player0 extends CharacterBody2D

@onready var world: World0 = get_parent()
@onready var facing_ray := $FacingDir
@onready var opp_facing_ray := $OppFacingDir
@onready var floor_detector_l := $FloorDetectorL
@onready var floor_detector_r := $FloorDetectorR
@onready var bullet_check := $BulletCheck
@onready var hitbox := $Hitbox
@onready var usebox := $Interactbox
@onready var _coll_shape := $CollisionShape2D
@onready var anim_sprite := $AnimatedSprite2D
@onready var anim_player := $AnimationPlayer
@onready var hitmark_sprite := $Hitmark

@export var DEFAULT_FACING_DIRECTION := Vector2(27, 0)
@export var DEFAULT_OPP_FACING_DIRECTION := Vector2(-27, 0)
@export var DEFAULT_GUN_FACING_DIRECTION := Vector2(3000, 0)
@export var JUMP_CUTOFF := 0.5 ## speed to slow down jump height after player releases jump button. used for variable jump height

# ------------------ const variables ----------------- #
const CLIMB_SPEED := 200.0
const WALK_SPEED := 300.0
const CROUCH_WALK_SPEED := 150.0
const JUMP_VELOCITY := -600.0
const CROUCH_JUMP_VELOCITY := -350.0
const WALL_JUMP_VELOCITY := -400.0
const WALL_SLIDE_VELOCITY := 100.0
const COYOTE_TIME_FLOOR := 6 ## frames after leaving floor for which the player can still jump

# ----------------------- enums ---------------------- #
## jump types. 
##
## GROUND: grounded jump
## CROUCH: grounded crouch jump
## WALL: wall jump
## GRABLESS: non-grab wall jump
enum JUMP_TYPE {NONE, GROUND, CROUCH, WALL, GRABLESS}

# ---------------------- signals ---------------------- #
signal died

# ----------------- public variables ----------------- #
var can_move := true
var can_interact: bool
var interactable: Area2D
var can_floor_jump: bool
var can_wall_jump: bool
var can_ng_wall_jump: bool
var can_climb_wall: bool
var is_grounded: bool
var is_crouching: bool
var is_climbing: bool
var is_wall_sliding: bool
var climbing_facing_direction: Vector2 ## the direction the player while climbing
var jump_type: JUMP_TYPE
var bullet_count: int = 10
var health : int

# ----------------- private variables ----------------- #
## value for which a frame timer will remain at when a timer is over.
const _TIMER_MIN_RESET := -1
## coyote timer countdown
var _coyote_time_floor_timer := COYOTE_TIME_FLOOR
## can the coyote timer start? will start if the player exactly one floor detector on one frame and zero on the next frame
var _can_start_coyote: bool
## has the coyote timer started?
var _coyote_started: bool
## is there exactly one floor detector colliding with the ground?
var _off_ledge: bool
## are there exactly zero floor detectors colliding with the ground where there was exactly one on the previous frame?
var _was_off_ledge: bool
## the direction the player was facing on the last input
var _last_direction: Vector2
## the type of the last valid jump the player made
var _last_jump_type: JUMP_TYPE
## max frames until the player can regrab a wall
const _REGRAB_MAX_FRAMES := 8
## current frames until the player can regrab a wall
var _frames_until_regrab := _TIMER_MIN_RESET
## is the player forced to crouch?
var _can_stand := true
## node the hitmark was locked onto
var _hitmark_lock: Node2D
## maximum health the player can have
var _max_health := 3
# Get the _gravity from the project settings to be synced with RigidBody nodes.
var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	anim_sprite.play("idle")
	health = _max_health

func _process(_delta):
	if Input.is_action_just_pressed("shoot") and bullet_count > 0:
		anim_sprite.play("shoot")
		anim_sprite.frame = 0 # reset shooting animation
		bullet_count -= 1
		# play bullet shot sound
		if bullet_check.is_colliding():
			var hit_item = bullet_check.get_collider()
			if hit_item is Enemy:
				_hitmark_lock = hit_item
				anim_player.play("target_hit")
				anim_player.seek(0) # reset hitmark animation
				# play enemy hit sound
				hit_item.take_damage()
				if hit_item.is_queued_for_deletion():
					# enemy just died
					bullet_count += 2
					_hitmark_lock = null
			elif hit_item is Bullet:
				# play bullet hit sound
				bullet_count += 1
				hit_item.die()
			else:
				# play wall hit sound
				pass
	if Input.is_action_just_pressed("use") and can_interact:
		if interactable is Door:
			interactable.use()
	if anim_player.is_playing():
		if _hitmark_lock:
			hitmark_sprite.position = _hitmark_lock.position - position
		else:
			hitmark_sprite.visible = false

func _physics_process(delta):
	can_climb_wall = facing_ray.is_colliding()
	can_wall_jump = is_climbing
	can_floor_jump = is_grounded and !is_climbing
	is_grounded = floor_detector_l.is_colliding() or floor_detector_r.is_colliding()
	can_ng_wall_jump = !is_grounded and !is_climbing and (facing_ray.is_colliding() or opp_facing_ray.is_colliding())
	_off_ledge = floor_detector_l.is_colliding() != floor_detector_r.is_colliding() # only one is not colliding
	_can_start_coyote = _was_off_ledge and !_off_ledge and !floor_detector_l.is_colliding()
	# coyote timing logic. i refuse to use timers for menial shit like this
	if _can_start_coyote or _coyote_started:
		if _coyote_time_floor_timer == _TIMER_MIN_RESET:
			can_floor_jump = false
			_coyote_started = false
			_can_start_coyote = false
		else:
			_coyote_time_floor_timer = int(move_toward(_coyote_time_floor_timer, _TIMER_MIN_RESET, 1))
			can_floor_jump = true
			_coyote_started = true
	else:
		_coyote_started = false
		_coyote_time_floor_timer = COYOTE_TIME_FLOOR

	# player can climb a wall if pressing "grab" and is either near a wall or already climbing
	if Input.is_action_pressed("grab") and (can_climb_wall or is_climbing) and _frames_until_regrab == _TIMER_MIN_RESET:
		if !is_climbing:
			# set climbing facing direction to the player's facing direction when they start climbing
			climbing_facing_direction = _last_direction
		is_climbing = true
		can_ng_wall_jump = false
		# can_wall_jump = true
	if is_climbing:
		var climb_direction := Input.get_axis("ui_up", "ui_down")
		if climb_direction:
			velocity.y = climb_direction * CLIMB_SPEED
			anim_sprite.play("climb")
		else:
			velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED) # slowdown effect
			anim_sprite.play("climb_idle")

	# hacky way to disable climbing when a wall runs out
	if !facing_ray.is_colliding() and !opp_facing_ray.is_colliding() and (can_climb_wall or is_climbing):
		is_climbing = false
		can_climb_wall = false

	if Input.is_action_just_released("grab"):
		is_climbing = false

	is_crouching = Input.is_action_pressed("crouch") and is_grounded and !is_climbing
	if is_crouching:
		_coll_shape.shape.size = Vector2(16, 16)
		_coll_shape.position = Vector2(0, 8)
	else:
		if _can_stand:
			_coll_shape.shape.size = Vector2(16, 32)
			_coll_shape.position = Vector2(0, 0)
		else:
			is_crouching = true
	if Input.is_action_just_released("crouch") and _can_stand:
		is_crouching = false
		if anim_sprite.animation == "crouch_idle":
			anim_sprite.stop()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var spd := CROUCH_WALK_SPEED if is_crouching else WALK_SPEED
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		_last_direction = Vector2(direction, 0).normalized()
		facing_ray.target_position = _last_direction * DEFAULT_FACING_DIRECTION
		opp_facing_ray.target_position = _last_direction * DEFAULT_FACING_DIRECTION * Vector2(-1, 0)
		bullet_check.target_position = _last_direction * DEFAULT_GUN_FACING_DIRECTION
		if !is_climbing:
			velocity.x = move_toward(velocity.x, direction * spd, spd / 10)
			anim_sprite.play("run")
		if is_crouching:
			anim_sprite.play("crouch")
	else:
		velocity.x = move_toward(velocity.x, 0, spd / 10) # slowdown effect
		if !is_climbing:
			facing_ray.target_position = _last_direction * DEFAULT_FACING_DIRECTION
		if is_crouching:
			anim_sprite.play("crouch_idle")
		if anim_sprite.animation == "run":
			anim_sprite.stop()

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		anim_sprite.play("jump")
		if can_floor_jump:
			if is_crouching:
				is_crouching = false
				velocity.y = CROUCH_JUMP_VELOCITY
				jump_type = JUMP_TYPE.CROUCH
			else:
				velocity.y = JUMP_VELOCITY
				jump_type = JUMP_TYPE.GROUND
		if can_wall_jump and _frames_until_regrab == _TIMER_MIN_RESET:
			_frames_until_regrab = _REGRAB_MAX_FRAMES
			velocity.y = JUMP_VELOCITY
			jump_type = JUMP_TYPE.WALL
			if is_climbing:
				is_climbing = false
		if can_ng_wall_jump:
			if facing_ray.is_colliding():
				velocity.x = facing_ray.target_position.normalized().x * WALL_JUMP_VELOCITY
			elif opp_facing_ray.is_colliding():
				velocity.x = opp_facing_ray.target_position.normalized().x * WALL_JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY - 100
			jump_type = JUMP_TYPE.GRABLESS
		_last_jump_type = jump_type
	else:
		jump_type = JUMP_TYPE.NONE


	# player slides down a wall if they are:
		# off the ground
		# not climbing the wall
		# close enough to climb the wall
		# moving into the wall
		# not moving or already moving down (to avoid interrupting a jump)
	is_wall_sliding = !is_grounded and !is_climbing and can_climb_wall and direction == facing_ray.target_position.normalized().x and velocity.y >= 0
	if not is_grounded:
		if !is_climbing:
			if can_climb_wall and direction == facing_ray.target_position.normalized().x and velocity.y >= 0:
				# if moving into a wall
				velocity.y = WALL_SLIDE_VELOCITY
				# anim_sprite.play("climb")
				# anim_sprite.offset = Vector2(7 * _last_direction.normalized().x, 0)
			else:
				# Add the _gravity.
				velocity.y += _gravity * delta
				anim_sprite.play("jump")
	else:
		if anim_sprite.animation == "jump":
			anim_sprite.stop()
	
	if is_grounded and !is_crouching and !direction and !anim_sprite.is_playing() and velocity.y == 0:
		anim_sprite.play("idle")

	_was_off_ledge = _off_ledge
	_frames_until_regrab = int(move_toward(_frames_until_regrab, _TIMER_MIN_RESET, 1))
	_track_direction()
	move_and_slide()

func _input(event):
	if event.is_action_released("jump"):
		if velocity.y < 0:
			velocity.y *= JUMP_CUTOFF

func check_death():
	if health <= 0:
		print("PLAYER DIED")
		died.emit()

func _track_direction():
	if _last_direction.x == -1:
		anim_sprite.flip_h = true
	elif _last_direction.x == 1:
		anim_sprite.flip_h = false

func _on_hitbox_area_entered(area: Area2D):
	if area is Bullet:
		area.queue_free()
		health -= 1
		check_death()


func _on_headbox_body_entered(body: Node2D):
	if !(body is Player0) and is_crouching:
		_coll_shape.shape.size = Vector2(16, 16)
		_coll_shape.position = Vector2(0, 8)
		_can_stand = false

func _on_headbox_body_exited(body: Node2D):
	if !(body is Player0):
		_coll_shape.shape.size = Vector2(16, 32)
		_coll_shape.position = Vector2(0, 0)
		_can_stand = true

func _on_interactbox_area_entered(area: Area2D):
	can_interact = true
	interactable = area

func _on_interactbox_area_exited(_area: Area2D):
	can_interact = false
	interactable = null
