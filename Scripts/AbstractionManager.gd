extends Node

## Abstraction layer enum
## CROWN: Layer 0/first layer
## GEM: Layer 1/second layer
## RING: Layer 2/third layer
enum AL {CROWN, GEM, RING}

var abs_layer: AL
var crown_scene := "wld"
var player0: Player0
var player0_pos: Vector2
var gem_scene: String
# var player1 : Node
var ring_scene := "RING_World"
var player2: Player2

var block_count: int
var active_bridge_struct: BridgeStruct
var active_bridge_num: int
var awaiting_bridge: bool

func descend_layer():
	match abs_layer:
		AL.CROWN:
			abs_layer = AL.RING
		# AL.GEM:
		# 	AM.abs_layer = AL.RING
		# AL.RING:
		# 	print("ERROR: CANNOT DESCEND FURTHER")
		_:
			print("ERROR: INVALID LAYER")

func descend_layer2(w: int, h: int, pos: Vector2):
	active_bridge_struct = BridgeStruct.new(w, h, pos)
	print("width")
	AM.awaiting_bridge = true
	print(abs_layer)
	match abs_layer:
		AL.CROWN:
			abs_layer = AL.RING
		# AL.GEM:
		# 	AM.abs_layer = AL.RING
		# AL.RING:
		# 	print("ERROR: CANNOT DESCEND FURTHER")
		_:
			print("ERROR: INVALID LAYER")

func ascend_layer():
	AM.block_count = 0
	match abs_layer:
		AL.RING:
			abs_layer = AL.CROWN
		# AL.GEM:
		# 	abs_layer = AL.CROWN
		# AL.CROWN:
		# 	print("ERROR: CANNOT ASCEND FURTHER")
		_:
			print("ERROR: INVALID LAYER")
