class_name Sticky extends Area2D

@onready var world: World2 = get_parent().get_parent()
@onready var player: Player2 = world.get_node("Player2")
@onready var stick_check_l : RayCast2D = $StickCheckL
@onready var stick_check_r : RayCast2D = $StickCheckR
@onready var stick_check_u : RayCast2D = $StickCheckU
@onready var stick_check_d : RayCast2D = $StickCheckD
@onready var coll : CollisionShape2D = $CollisionShape2D
@export var TILE_SIZE := 18

## is this Sticky object attached to the player/another Sticky object?
var is_attached := false

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if stick_check_l.is_colliding() and stick_check_l.get_collider() is Sticky and !stick_check_l.get_collider().is_attached:
		stick_check_l.enabled = false
		var c := stick_check_l.get_collider() as Sticky
		c.is_attached = true
		c.reparent(player, true)
		SB.sticky_joined.emit()
		# stick_check_u.force_raycast_update() # check collision immediately
	if stick_check_u.is_colliding() and stick_check_u.get_collider() is Sticky and !stick_check_u.get_collider().is_attached:
		stick_check_u.enabled = false
		var c := stick_check_u.get_collider() as Sticky
		c.is_attached = true
		c.reparent(player, true)
		SB.sticky_joined.emit()
		# stick_check_d.force_raycast_update() # check collision immediately
	if stick_check_d.is_colliding() and stick_check_d.get_collider() is Sticky and !stick_check_d.get_collider().is_attached:
		stick_check_d.enabled = false
		var c := stick_check_d.get_collider() as Sticky
		c.is_attached = true
		c.reparent(player, true)
		SB.sticky_joined.emit()
		# stick_check_r.force_raycast_update() # check collision immediately
	if stick_check_r.is_colliding() and stick_check_r.get_collider() is Sticky and !stick_check_r.get_collider().is_attached:
		stick_check_r.enabled = false
		var c := stick_check_r.get_collider() as Sticky
		c.is_attached = true
		c.reparent(player, true)
		SB.sticky_joined.emit()
		# stick_check_l.force_raycast_update() # check collision immediately

func setup(pos: Vector2):
	position = pos.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE/2


func p_reparent(wld: World2, plr: Player2):
	world = wld
	player = plr

func _on_area_entered(area: Area2D):
	if area.name == "Target":
		# world.ascend_layer()
		pass
