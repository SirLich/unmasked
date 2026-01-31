extends Node2D
@export var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player.play("spawn")
	await animation_player.animation_finished
	self.queue_free()
