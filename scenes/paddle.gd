class_name Paddle extends CharacterBody2D

@export var speed: float = 600
# TODO accel/decel?

var original_position: Vector2

func _ready():
	original_position = position
	
func reset():
	position = original_position

func _process(_delta: float) -> void:
	var dir = 0
	if Input.is_action_pressed("left"):
		dir -= 1
	if Input.is_action_pressed("right"):
		dir += 1
	velocity.x = dir * speed
	move_and_slide()
