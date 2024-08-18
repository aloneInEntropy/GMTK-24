class_name Player2 extends Area2D

@onready var world: World2 = get_parent()
@onready var ob_check : RayCast2D = $ObCheck

@export var DEFAULT_FACING_DIRECTION := Vector2(27, 0)
@export var DEFAULT_OPP_FACING_DIRECTION := Vector2(-27, 0)
@export var GRID_SIZE := Vector2(18, 18)

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

# ----------------- private variables ----------------- #
## value for which a frame timer will remain at when a timer is over.
const _TIMER_MIN_RESET := -1
## coyote timer countdown
var _movement_timer := MOVEMENT_MAX_TIME
## the direction the player was facing on the last input
var _last_direction : Vector2

func _ready():
	position = position.snapped(Vector2.ONE * GRID_SIZE)
	position += Vector2.ONE * GRID_SIZE/2

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
		ob_check.target_position = direction * GRID_SIZE
		ob_check.force_raycast_update() # check collision immediately
		if !ob_check.is_colliding():
			_movement_timer = MOVEMENT_MAX_TIME
			_last_direction = direction.normalized()
			position += direction * GRID_SIZE

	_movement_timer = int(move_toward(_movement_timer, _TIMER_MIN_RESET, 1))

# func _input(event : InputEvent):

func check_death():
	if false:
		print("PLAYER DIED")
		died.emit()

func _on_area_entered(area:Area2D):
	if area.name == "Target":
		world.ascend_layer()