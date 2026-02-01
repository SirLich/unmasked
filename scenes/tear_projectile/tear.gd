extends Node2D

@export var speed = 400
@export var animation_player: AnimationPlayer

func _physics_process(delta: float) -> void:
	global_position += Vector2.DOWN.rotated(rotation) * delta * speed

func _ready() -> void:
	await animation_player.animation_finished
	queue_free()
