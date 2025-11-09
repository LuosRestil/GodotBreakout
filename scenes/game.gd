extends Node2D

const BRICK = preload("uid://be6m7brci0ic2")

@onready var level_1: Node2D = $Levels/Level1
@onready var level_2: Node2D = $Levels/Level2
@onready var level_3: Node2D = $Levels/Level3
@onready var level_4: Node2D = $Levels/Level4
@onready var level_5: Node2D = $Levels/Level5
@onready var paddle: Paddle = $Paddle
@onready var ball: Ball = $Ball
@onready var lives_label: Label = $UI/LivesLabel
@onready var score_label: Label = $UI/ScoreLabel

const ball_speed: float = 600
var levels: Array[Node2D]
var level_idx := 0
var brick_count: int

var paddle_pos: Vector2
var lives: int:
	set(value):
		lives = value
		lives_label.text = str(lives)
var score: int:
	set(value):
		score = value
		score_label.text = str(score)


func _ready():
	levels.append(level_1)
	levels.append(level_2)
	levels.append(level_3)
	levels.append(level_4)
	levels.append(level_5)
	reset()
	
	
func reset():
	lives = 3
	score = 0
	_load_level(level_1)
	
	
func _physics_process(_delta: float) -> void:
	ball.get_paddle_pos(paddle.position)
		
		
func _load_level(level: Node2D):
	ball.reset()
	paddle.reset()
	ball.speed = ball_speed
	ball.get_paddle_pos(paddle.position)
	var tilemap: TileMapLayer = level.get_node("BrickMap")
	var tile_positions := tilemap.get_used_cells()
	brick_count = len(tile_positions)
	for tile_position in tile_positions:
		var pos := tilemap.map_to_local(tile_position)
		var brick := BRICK.instantiate()
		level.add_child(brick)
		brick.position = pos
		brick.brick_hit.connect(_on_brick_hit)
		brick.add_to_group("bricks")
	tilemap.queue_free()
	

func _on_bottom_area_entered(_area: Area2D) -> void:
	lives -= 1
	ball.reset()
	paddle.reset()
	if lives == 0:
		game_over()
		
		
func _on_brick_hit():
	score += 1
	ball.speed += 10
	brick_count -= 1
	if brick_count == 0:
		level_idx += 1
		if level_idx < len(levels):
			_load_level(levels[level_idx])
		else:
			win()
	
	
func win() -> void:
	print("You win!")
	
	
func game_over():
	print("game over")
