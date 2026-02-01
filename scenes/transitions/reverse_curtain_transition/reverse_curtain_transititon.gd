extends Transition
class_name ReverseCurtainTransition

@export var fade_color : Color
@export var fade_in_time = 2.0
@export var fade_out_time = 2.0
@export var fade_scene : PackedScene

func start_transition(old_scene : Node, fade_slot : Node, scene_slot : Node, new_scene : PackedScene):
	for child in old_scene.get_children():
		child.queue_free()
	var tree = old_scene.get_tree()
	
	
	var active_fade = fade_scene.instantiate()
	var curtain_left = active_fade.find_child("CurtainLeft") as TextureRect
	var curtain_right = active_fade.find_child("CurtainRight") as TextureRect
	curtain_left.position += Vector2(-900, 0)
	curtain_right.position += Vector2(900, 0)
	fade_slot.add_child(active_fade)
	
	#var fade_out_tween = tree.create_tween()
	#fade_out_tween.tween_property(active_fade, "color", fade_color, fade_out_time)
	
	var curtain_right_tween = tree.create_tween()
	var curtain_left__tween = tree.create_tween()
	curtain_right_tween.tween_property(curtain_left, "position", curtain_left.position - Vector2(-900, 0), fade_out_time)
	curtain_left__tween.tween_property(curtain_right, "position", curtain_right.position - Vector2(900, 0), fade_out_time)

	#await fade_out_tween.finished
	await curtain_right_tween.finished
	#SceneManager.change_to_packed(new_scene)
	SceneManager.change_to_packed(new_scene)

	##
	#var fade_in_tween = tree.create_tween()
	#fade_in_tween.tween_property(active_fade, "color", Color(0, 0, 0, 0), fade_in_time)
##
	#await fade_in_tween.finished
	active_fade.queue_free()
