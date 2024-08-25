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

var descending := false
var ascending := false

var block_count: int = 0
var active_bridge_struct: BridgeStruct
var active_bridge_num: int
var awaiting_bridge: bool
var active_terminal: String ## name of active terminal
var terminals: Dictionary ## Dictionary[String, Bridge] of terminals

## Dictionary[String, Dictionary[String, Bridge]] of terminals in each level
var lvl_terminals: Dictionary = {
	"level_1": null,
	"level_2": null,
	"level_3": null,
	"level_4": null,
	"level_5": null,
	"level_test": null,
}

func descend_layer(w: int, h: int, pos: Vector2):
	if terminals.has(active_terminal):
		active_bridge_struct = terminals[active_terminal]
	else:
		active_bridge_struct = BridgeStruct.new(w, h, pos)
	AM.awaiting_bridge = true
	descending = true

func ascend_layer():
	ascending = true
	GM.load_reason = GM.LOAD_REASON.AT_TERMINAL

func reset_active_terminal(returned_tiles_count: int):
	print(returned_tiles_count)
	if active_bridge_struct.complete:
		# only return count if the bridge was actually built
		block_count += returned_tiles_count
	active_bridge_struct = BridgeStruct.new(active_bridge_struct.width, active_bridge_struct.height, active_bridge_struct.position)
	terminals[active_terminal] = active_bridge_struct

func update_bridge(vs: PackedVector2Array):
	var prev_size := active_bridge_struct.bridge_vectors.size()
	# print(vs.size() - prev_size)
	block_count -= vs.size() - prev_size
	active_bridge_struct.create_bridge(vs)
	active_bridge_struct.complete = true
	terminals[active_terminal] = active_bridge_struct
	lvl_terminals[crown_scene] = terminals
