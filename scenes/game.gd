extends Node2D

const BRICK = preload("uid://be6m7brci0ic2")

@onready var level_1: Node2D = $Level1

func _ready():
	_load_level(level_1)
		
func _load_level(level: Node2D):
	var tilemap: TileMapLayer = level.get_node("TileMapLayer")
	var tile_positions := tilemap.get_used_cells()
	for tile_position in tile_positions:
		var pos := tilemap.map_to_local(tile_position)
		var brick := BRICK.instantiate()
		level.add_child(brick)
		brick.position = pos
	tilemap.queue_free()
	
