extends StaticBody2D

signal brick_hit

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func take_hit():
	particles.emitting = true
	collision_shape_2d.disabled = true
	sprite.visible = false
	brick_hit.emit()


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
