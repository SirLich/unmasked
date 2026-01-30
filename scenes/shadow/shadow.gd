@tool
extends Node2D
class_name Shadow

@export var shadow_size = 10

func _process(delta: float) -> void:
	queue_redraw()
	
func _draw():
	var shadow_color = Color.BLACK
	shadow_color.a = 0.2
	draw_circle(Vector2.ZERO, shadow_size, shadow_color)
