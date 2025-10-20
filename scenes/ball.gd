class_name Ball extends Node2D

#@onready var paddle_sound: AudioStreamPlayer = $PaddleSound
#@onready var wall_sound: AudioStreamPlayer = $WallSound
@onready var sprite: Polygon2D = $Sprite
@onready var cast: ShapeCast2D = $ShapeCast2D

var direction: Vector2
var start_pos: Vector2
var radius: float = 10
var base_speed := 600.0
var speed := 0.0
var velocity: Vector2 = Vector2.DOWN
var active := false
var paddle_pos: Vector2

func _ready():
	start_pos = position
	sprite.polygon = _make_circle_points(radius)
	reset()
	

func _process(_delta: float) -> void:
	if active: return
	if Input.is_action_just_pressed("action"):
		velocity = speed * direction
		active = true


func _physics_process(delta: float) -> void:		
	if not active:
		position.x = paddle_pos.x
		return

	var motion := velocity * delta
	
	cast.global_position = global_position
	cast.target_position = motion
	cast.force_shapecast_update()
	
	var remaining_dist: float = 1
	var iterations: int = 0
	while iterations < 4 and remaining_dist > 0.0 and cast.is_colliding():
		iterations += 1
		
		var safe_frac = cast.get_closest_collision_safe_fraction()
		# advance to cntact point
		position += motion * safe_frac
		remaining_dist *= (1 - safe_frac)
		# sum normals, trigger brick hit code
		var normal_sum: Vector2 = Vector2.ZERO
		var collision_count = cast.get_collision_count()
		for i in collision_count:
			var collider: Object = cast.get_collider(i)
			var normal := cast.get_collision_normal(i)
			if collider is Paddle and collision_count == 1:
				var hit_x := cast.get_collision_point(i).x
				normal = _get_modified_normal(collider, velocity, hit_x)
			if abs(velocity.dot(normal)) > 0.0001:
				if collider.has_method("take_hit"):
					collider.take_hit()
				normal_sum += normal

		if normal_sum != Vector2.ZERO:
			velocity = velocity.bounce(normal_sum.normalized())
		
		# recast remaining distance after bounce
		motion = delta * remaining_dist * velocity
		cast.global_position = global_position
		cast.target_position = motion
		cast.force_shapecast_update()
	
	position += motion
	velocity = velocity.normalized() * speed
	
	
func reset():
	position = start_pos
	active = false
	direction = Vector2.UP
	speed = base_speed
	
	
func _get_modified_normal(paddle: Paddle, v_in: Vector2, hit_x: float) -> Vector2:
	var collision_shape := paddle.get_node("CollisionShape2D") as CollisionShape2D
	var rect := collision_shape.shape as RectangleShape2D
	var half_w: float = rect.size.x * 0.5
	var center := paddle.global_position.x
	var pct: float = inverse_lerp(center - half_w, center + half_w, hit_x)
	var theta: float = lerp(-PI + PI/8, -PI/8, pct)
	var v_out := Vector2.from_angle(theta).normalized()
	# normal of surface that produces v_out from v_in
	return (v_in.normalized() - v_out).normalized()
	
	
func _make_circle_points(circle_radius: float, resolution: int = 32) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	for i in resolution:
		var angle := TAU * i / resolution
		pts.append(Vector2.from_angle(angle) * circle_radius)
	return pts
	

func get_paddle_pos(pos: Vector2):
	paddle_pos = pos
