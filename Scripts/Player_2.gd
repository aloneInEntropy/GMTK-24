class_name Player2 extends Area2D

@onready var world: World2 = get_parent()
@onready var ob_check : RayCast2D = $ObCheck
@onready var stick_check_l : RayCast2D = $StickCheckL
@onready var stick_check_r : RayCast2D = $StickCheckR
@onready var stick_check_u : RayCast2D = $StickCheckU
@onready var stick_check_d : RayCast2D = $StickCheckD
@onready var coll : CollisionShape2D = $CollisionShape2D

@export var DEFAULT_FACING_DIRECTION := Vector2(27, 0)
@export var DEFAULT_OPP_FACING_DIRECTION := Vector2(-27, 0)
@export var TILE_SIZE := 18

# ------------------ const variables ----------------- #
## max frames before the player can move again
const MOVEMENT_MAX_TIME := 4
# ----------------------- enums ---------------------- #

# ---------------------- signals ---------------------- #
signal died

# ----------------- public variables ----------------- #
var can_move := true
var can_interact: bool
var interactable: Area2D
var pos_array : PackedVector2Array

# ----------------- private variables ----------------- #
## value for which a frame timer will remain at when a timer is over.
const _TIMER_MIN_RESET := -1
## coyote timer countdown
var _movement_timer := MOVEMENT_MAX_TIME
## the direction the player was facing on the last input
var _last_direction : Vector2
var group_width_left : int = TILE_SIZE
var group_width_right : int = TILE_SIZE
var group_height_up : int = TILE_SIZE
var group_height_down : int = TILE_SIZE

func _ready():
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE/2
	SB.sticky_joined.connect(handle_sticky_joined)

func _process(_delta):
	pass

func _physics_process(_delta):
	var direction : Vector2
	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2(-1, 0)
	if Input.is_action_just_pressed("ui_right"):
		direction = Vector2(1, 0)
	if Input.is_action_just_pressed("ui_up"):
		direction = Vector2(0, -1)
	if Input.is_action_just_pressed("ui_down"):
		direction = Vector2(0, 1)
	if direction and _movement_timer == _TIMER_MIN_RESET:
		recalculate_group_sizes(get_sticky_children())
		var check_dist := expand_check(direction)
		ob_check.target_position = direction * check_dist
		ob_check.force_raycast_update() # check collision immediately
		if !ob_check.is_colliding():
			_movement_timer = MOVEMENT_MAX_TIME
			_last_direction = direction.normalized()
			position += direction * TILE_SIZE
	if stick_check_l.is_colliding() and stick_check_l.get_collider() is Sticky:
		## LEFT
		stick_check_l.enabled = false
		group_width_left += TILE_SIZE
		var c := stick_check_l.get_collider() as Sticky
		c.is_attached = true
		c.stick_check_r.enabled = false
		c.reparent(self)
		c.p_reparent(world, self)
		SB.sticky_joined.emit()
		# stick_check_u.force_raycast_update() # check collision immediately
	if stick_check_u.is_colliding() and stick_check_u.get_collider() is Sticky:
		## UP
		stick_check_u.enabled = false
		group_height_up += TILE_SIZE
		var c := stick_check_u.get_collider() as Sticky
		c.is_attached = true
		c.stick_check_d.enabled = false
		c.reparent(self)
		c.p_reparent(world, self)
		SB.sticky_joined.emit()
		# stick_check_d.force_raycast_update() # check collision immediately
	if stick_check_d.is_colliding() and stick_check_d.get_collider() is Sticky:
		## DOWN
		group_height_down += TILE_SIZE
		stick_check_d.enabled = false
		var c := stick_check_d.get_collider() as Sticky
		c.is_attached = true
		c.stick_check_u.enabled = false
		c.reparent(self)
		# stick_check_r.force_raycast_update() # check collision immediately
		c.p_reparent(world, self)
		SB.sticky_joined.emit()
	if stick_check_r.is_colliding() and stick_check_r.get_collider() is Sticky:
		## RIGHT
		stick_check_r.enabled = false
		group_width_right += TILE_SIZE
		var c := stick_check_r.get_collider() as Sticky
		c.is_attached = true
		c.stick_check_l.enabled = false
		c.reparent(self)
		# stick_check_l.force_raycast_update() # check collision immediately
		c.p_reparent(world, self)
		SB.sticky_joined.emit()
	_movement_timer = int(move_toward(_movement_timer, _TIMER_MIN_RESET, 1))

func _input(event):
	if event.is_action_pressed("submit"):
		print(pos_array)
		SB.bridge_submitted.emit(pos_array)

func check_can_move() -> bool:
	return true

func get_sticky_children() -> Array:
	var children = get_children().reduce(func(accum:Array, child:Node):
		if child is Sticky:
			accum.push_back(child)
		return accum, []) as Array
	return children

func handle_sticky_joined():
	recalculate_group_sizes(get_sticky_children())

func recalculate_group_sizes(stickies: Array):
	var poss := []
	if !stickies.is_empty():
		var _group_width_left := TILE_SIZE
		var _group_width_right := TILE_SIZE
		var _group_height_up := TILE_SIZE
		var _group_height_down := TILE_SIZE

		for sticky in stickies:
			poss.append(sticky.position)
			_group_width_left = min(_group_width_left, sticky.position.x)
			_group_width_right = max(_group_width_right, sticky.position.x)
			_group_height_up = min(_group_height_up, sticky.position.y)
			_group_height_down = max(_group_height_down, sticky.position.y)
		
		# only add TILE_SIZE if that side has a tile on it, otherwise ignore it
		if _group_width_left != TILE_SIZE: 
			group_width_left = abs(_group_width_left) + TILE_SIZE 
		if group_width_right != TILE_SIZE: 
			group_width_right = abs(_group_width_right) + TILE_SIZE 
		if group_height_up != TILE_SIZE: 
			group_height_up = abs(_group_height_up) + TILE_SIZE 
		if group_height_down != TILE_SIZE: 
			group_height_down = abs(_group_height_down) + TILE_SIZE 
		
		pos_array = poss.map(func(p):
			return p / TILE_SIZE
		)


func expand_check(dir : Vector2) -> int:
	var check_dist = TILE_SIZE
	match dir:
		Vector2(-1, 0):
			check_dist = group_width_left
		Vector2(1, 0):
			check_dist = group_width_right
		Vector2(0, -1):
			check_dist = group_height_up
		Vector2(0, 1):
			check_dist = group_height_down
		_:
			pass
	return check_dist

func _on_area_entered(area:Area2D):
	if area.name == "Target":
		world.ascend_layer()
	# if area.name == "Follow":
	# 	area.reparent(self)
	# 	# todo: sticky targets of class Sticky. 4 StickCheck raycasts in cardinal directions checking for Sticky collision mask 8

