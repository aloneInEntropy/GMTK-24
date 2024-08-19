class_name BridgeStruct

var width : int
var height : int
var position : Vector2
var bridge_vectors : PackedVector2Array
var complete := false

func _init(w: int, h: int, pos := Vector2()):
    width = w
    height = h
    position = pos

func create_bridge(bv : PackedVector2Array):
    bridge_vectors = bv
    complete = true
