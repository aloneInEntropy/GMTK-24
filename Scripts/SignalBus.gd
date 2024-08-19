extends Node

signal sticky_joined()
signal using_terminal(sz: Vector2i, pos: Vector2i, term: Terminal)
signal building_bridge(blocks: int)
signal bridge_submitted(vs: PackedVector2Array)
signal bridge_reset(used_tiles: int)
signal show_bridge(show: bool, cam_pos: Vector2)
