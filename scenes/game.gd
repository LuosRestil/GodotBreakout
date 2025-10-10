extends Node2D

const BRICK = preload("uid://be6m7brci0ic2")

@onready var level_1: Node2D = $Level1
@onready var paddle: Paddle = $Paddle
@onready var ball: Ball = $Ball
@onready var lives_label: Label = $UI/LivesLabel

var paddle_pos: Vector2
var lives: int:
	set(value):
		lives = value
		lives_label.text = str(lives)


func _ready():
	lives = 3
	_load_level(level_1)
	ball.get_paddle_pos(paddle.position)
	
	
func _physics_process(_delta: float) -> void:
	ball.get_paddle_pos(paddle.position)
		
		
func _load_level(level: Node2D):
	var tilemap: TileMapLayer = level.get_node("TileMapLayer")
	var tile_positions := tilemap.get_used_cells()
	for tile_position in tile_positions:
		var pos := tilemap.map_to_local(tile_position)
		var brick := BRICK.instantiate()
		level.add_child(brick)
		brick.position = pos
	tilemap.queue_free()
	
	
func game_over():
	print("game over")


func _on_bottom_area_entered(_area: Area2D) -> void:
	lives -= 1
	ball.reset()
	paddle.reset()
	if lives == 0:
		game_over()
