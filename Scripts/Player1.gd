class_name Player0 extends CharacterBody2D

@onready var world := get_parent()
@onready var floor_detector_l := $FloorDetectorL
@onready var floor_detector_r := $FloorDetectorR
@onready var bullet_check := $BulletCheck
@onready var bullet_line: Line2D = $BulletLine
@onready var hitbox := $Hitbox
@onready var usebox := $Interactbox
@onready var _coll_shape := $CollisionShape2D
@onready var anim_sprite := $AnimatedSprite2D
@onready var anim_player := $AnimationPlayer
@onready var hitmark_sprite := $Hitmark

@export var DEFAULT_FACING_DIRECTION := Vector2(17, 0)
@export var DEFAULT_OPP_FACING_DIRECTION := Vector2(-17, 0)
@export var DEFAULT_GUN_FACING_DIRECTION := Vector2(400, 0)
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
const BULLET_LINE_DIST := 400.0

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
var health: int
# var is_aiming : bool ## are the hitmark sprite and bullet line visible?

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
var _is_left_colliding: bool
var _is_right_colliding: bool
var _facing_dir : Vector2
var _opp_facing_dir : Vector2
# var _tile_facing_dir : Vector2
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
var _max_health := 5
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
				# play enemy hit sound
				hit_item.take_damage()
				if hit_item.is_queued_for_deletion():
					# enemy just died
					bullet_count += 1
					AM.block_count += 3
					_hitmark_lock = null
			elif hit_item is Bullet:
				# play bullet hit sound
				hit_item.die()
			else:
				# play wall hit sound
				pass
	if Input.is_action_just_pressed("use") and can_interact:
		can_interact = false
		if interactable is Door:
			interactable.use()
		if interactable is Terminal:
			interactable.use()
	if anim_player.is_playing():
		if _hitmark_lock:
			hitmark_sprite.position = _hitmark_lock.position - position
		else:
			hitmark_sprite.visible = false

func _physics_process(delta):
	if bullet_check.is_colliding() and (bullet_check.get_collider() is Enemy or bullet_check.get_collider() is Bullet):
		_hitmark_lock = bullet_check.get_collider()
		hitmark_sprite.visible = true
		bullet_line.visible = true
		hitmark_sprite.position = _hitmark_lock.position - position
		bullet_line.points[-1] = Vector2(_last_direction.x * abs(hitmark_sprite.position.x), hitmark_sprite.position.y)
	else:
		_hitmark_lock = null
		hitmark_sprite.visible = false
		bullet_line.visible = false

	var is_facing_colliding : bool
	var is_opp_facing_colliding : bool
	if _last_direction == Vector2.LEFT:
		is_facing_colliding = _is_left_colliding
		is_opp_facing_colliding = _is_right_colliding
	else:
		is_facing_colliding = _is_right_colliding
		is_opp_facing_colliding = _is_left_colliding

	can_climb_wall = is_facing_colliding
	can_wall_jump = is_climbing
	can_floor_jump = is_grounded and !is_climbing
	is_grounded = floor_detector_l.is_colliding() or floor_detector_r.is_colliding()
	can_ng_wall_jump = !is_grounded and !is_climbing and (is_facing_colliding or is_opp_facing_colliding)
	_off_ledge = floor_detector_l.is_colliding() != floor_detector_r.is_colliding() # only one is not colliding
	_can_start_coyote = _was_off_ledge and !_off_ledge and !floor_detector_l.is_colliding()
	
	# coyote timing logic
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
	else:
		if anim_sprite.animation == "climb" or "climb_idle":
			anim_sprite.stop()

	# hacky way to disable climbing when a wall runs out
	if !is_facing_colliding and !is_opp_facing_colliding and (can_climb_wall or is_climbing):
		is_climbing = false
		can_climb_wall = false

	if Input.is_action_just_released("grab"):
		is_climbing = false

	is_crouching = Input.is_action_pressed("crouch") and !is_climbing and (is_grounded or (_last_jump_type == JUMP_TYPE.CROUCH and velocity.y < 0))
	if is_crouching:
		set_collision_shapes(true)
	else:
		if _can_stand:
			set_collision_shapes(false)
		else:
			is_crouching = true
	if (Input.is_action_just_released("crouch") or !is_crouching) and _can_stand:
		is_crouching = false
		if anim_sprite.animation == "crouch_idle":
			anim_sprite.stop()

	var spd := CROUCH_WALK_SPEED if is_crouching else WALK_SPEED
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		_last_direction = Vector2(direction, 0).normalized()
		_facing_dir = _last_direction
		_opp_facing_dir	= _facing_dir * -1
		bullet_check.target_position = _last_direction * DEFAULT_GUN_FACING_DIRECTION
		if !is_climbing:
			velocity.x = move_toward(velocity.x, direction * spd, spd / 10)
			if is_crouching or _last_jump_type == JUMP_TYPE.CROUCH:
				anim_sprite.play("crouch")
			else:
				anim_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, spd / 10) # slowdown effect
		if is_climbing:
			_last_direction = climbing_facing_direction
			_facing_dir = _last_direction
			_opp_facing_dir	= _facing_dir * -1
		else:
			_facing_dir = _last_direction
			_opp_facing_dir	= _facing_dir * -1
		if is_crouching:
			anim_sprite.play("crouch_idle")
		if anim_sprite.animation == "run":
			anim_sprite.stop()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and _can_stand:
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
			if is_facing_colliding:
				velocity.x = _facing_dir.x * WALL_JUMP_VELOCITY
			elif is_opp_facing_colliding:
				velocity.x = _opp_facing_dir.x * WALL_JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY - 100
			jump_type = JUMP_TYPE.GRABLESS
		_last_jump_type = jump_type
	else:
		jump_type = JUMP_TYPE.NONE


	# player slides down a wall if they are:
		# off the ground
		# not crouching or climbing the wall
		# close enough to climb the wall
		# moving into the wall
		# not moving or already moving down (to avoid interrupting a jump)
	is_wall_sliding = !is_grounded and !is_climbing and can_climb_wall and direction == _facing_dir.x and velocity.y >= 0
	if not is_grounded:
		if !is_climbing:
			if can_climb_wall and direction == _facing_dir.x and velocity.y >= 0:
				# if moving into a wall
				velocity.y = WALL_SLIDE_VELOCITY
			else:
				# Add the _gravity.
				velocity.y += _gravity * delta
				if _can_stand:
					anim_sprite.play("jump")
	else:
		if anim_sprite.animation == "jump":
			anim_sprite.stop()
	
	if is_grounded and !is_crouching and !is_climbing and !direction and !anim_sprite.is_playing() and velocity.y == 0:
		anim_sprite.play("idle")

	_was_off_ledge = _off_ledge
	_frames_until_regrab = int(move_toward(_frames_until_regrab, _TIMER_MIN_RESET, 1))
	_track_direction()
	move_and_slide()

func _input(event):
	if event.is_action_released("jump"):
		if velocity.y < 0:
			velocity.y *= JUMP_CUTOFF

## Checks the player's health. If their health is 0, kill the player by emitting the `died` signal
func check_death():
	if health <= 0:
		can_interact = false
		print("PLAYER DIED")
		died.emit()

## Tracks the direction the player is facing using `_last_direction` and updates the sprite accordingly
func _track_direction():
	if !is_climbing:
		if _last_direction.x == -1:
			anim_sprite.flip_h = true
		elif _last_direction.x == 1:
			anim_sprite.flip_h = false

## Checkes the player's crouch state and updates its collision hitboxes accordingly
func set_collision_shapes(crouching: bool):
	if crouching:
		_coll_shape.shape.size = Vector2(16, 16)
		_coll_shape.position = Vector2(0, 8)
		hitbox.get_child(0).shape.size = Vector2(24, 12)
		hitbox.get_child(0).position = Vector2(0, 6)
	else:
		_coll_shape.shape.size = Vector2(16, 32)
		_coll_shape.position = Vector2(0, 0)
		hitbox.get_child(0).shape.size = Vector2(24, 24)
		hitbox.get_child(0).position = Vector2(0, 0)
	pass

func _on_hitbox_area_entered(area: Area2D):
	if area is Bullet:
		area.queue_free()
		health -= 1
		check_death()
	else:
		print(area.name)

func _on_headbox_body_entered(body: Node2D):
	print(body.name)
	if !(body is Player0):
		set_collision_shapes(true)
		_can_stand = false

func _on_headbox_body_exited(body: Node2D):
	if !(body is Player0) and velocity.y >= 0:
		set_collision_shapes(false)
		_can_stand = true

func _on_interactbox_area_entered(area: Area2D):
	can_interact = true
	interactable = area
	if area is Terminal:
		SB.show_bridge.emit(true, area.bridge_position)

func _on_interactbox_area_exited(area: Area2D):
	can_interact = false
	interactable = null
	if area is Terminal:
		SB.show_bridge.emit(false, area.bridge_position)

func _on_death_box_area_entered(_area: Area2D):
	health = 0
	check_death()


func _on_hitbox_body_entered(_body: Node2D):
	# if _body is TileMap:
	# 	var _dir = climbing_facing_direction if is_climbing else _last_direction
	# 	var local_map_pos = _body.local_to_map(position) + Vector2i(_dir)
	# 	var _facing_tile = _body.get_cell_source_id(GM.TILEMAP_LAYER.WALL, local_map_pos, true)
	# 	_tile_facing_dir = (Vector2(local_map_pos.x*GM.TILE_SIZE, 0) - Vector2(position.x, 0)).normalized()
	# 	_is_facing_colliding = !(_tile_facing_dir != _dir and _facing_tile == -1)
	# 	_is_opp_facing_colliding = !(_tile_facing_dir == _dir and _facing_tile == -1)
	# 	# print("local map pos: {0}\ntile id: {1}\n{2}\nwall facing dir: {3}\nopp wall facing dir: {4}".format([
	# 	# 	local_map_pos,
	# 	# 	_body.get_cell_source_id(GM.TILEMAP_LAYER.WALL, local_map_pos, true), 
	# 	# 	"entering " + _body.name,
	# 	# 	_tile_facing_dir,
	# 	# 	_tile_facing_dir * -1
	# 	# 	]))
	pass

func _on_hitbox_body_exited(_body: Node2D):
	# if _body is TileMap:
	# 	var _dir = climbing_facing_direction if is_climbing else _last_direction
	# 	var local_map_pos = _body.local_to_map(position) + Vector2i(_dir)
	# 	var _facing_tile = _body.get_cell_source_id(GM.TILEMAP_LAYER.WALL, local_map_pos, true)
	# 	_tile_facing_dir = (Vector2(local_map_pos.x*GM.TILE_SIZE, 0) - Vector2(position.x, 0)).normalized()
	# 	_is_facing_colliding = !(_tile_facing_dir != _dir and _facing_tile == -1)
	# 	_is_opp_facing_colliding = !(_tile_facing_dir == _dir and _facing_tile == -1)
	# 	print("local map pos: {0}\ntile id: {1}\n{2}\nwall facing dir: {3}\nopp wall facing dir: {4}\n".format([
	# 		local_map_pos,
	# 		_facing_tile, 
	# 		"exiting " + _body.name,
	# 		_tile_facing_dir,
	# 		_tile_facing_dir * -1
	# 		]))
	pass

func _on_facing_l_area_entered(_area: Area2D):
	pass

func _on_facing_l_area_exited(_area: Area2D):
	pass

func _on_facing_r_area_entered(_area: Area2D):
	pass

func _on_facing_r_area_exited(_area: Area2D):
	pass


func _on_facing_l_body_entered(_body:Node2D):
	_is_left_colliding = true
	print("l entered")

func _on_facing_l_body_exited(_body:Node2D):
	_is_left_colliding = false
	print("l left")

func _on_facing_r_body_entered(_body:Node2D):
	_is_right_colliding = true
	print("r entered")

func _on_facing_r_body_exited(_body:Node2D):
	_is_right_colliding = false
	print("r left")
