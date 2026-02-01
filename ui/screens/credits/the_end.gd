extends Node

@export_file() var credits_file

@export var intro_animation:AnimatedSprite2D

@export var rope_rip_sound : AudioStream
@export var rope_wobble_sound : AudioStream

@export var credits_text : MarkdownLabel
@export var end_text : Label
@export var menu_button : TextureButton

func _ready():
	end_text.modulate.a = 0
	credits_text.modulate.a = 0
	menu_button.modulate.a = 0
	credits_text.display_file(credits_file)
	
	intro_animation.play("thread part 1")
	await intro_animation.animation_finished
	SoundManager.play_sound(rope_wobble_sound)
	intro_animation.play("thread part 2")
	await intro_animation.animation_finished
	SoundManager.play_sound(rope_rip_sound)
	intro_animation.play("thread part 3")
	
	var end_fade_in := create_tween()
	end_fade_in.tween_property(end_text, "modulate:a", 1.0, 2.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	var move_end := create_tween()
	move_end.tween_property(
		end_text,
		"position:y",
		end_text.position.y - 700,
		4
	).set_trans(Tween.TRANS_LINEAR)
	
	#await move_end.finished
	
	var credits_fade_in := create_tween()
	credits_fade_in.tween_interval(5)
	credits_fade_in.tween_property(credits_text, "modulate:a", 1.0, 2.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	var move_credits := create_tween()
	move_credits.tween_interval(4)
	move_credits.tween_property(
		credits_text,
		"position:y",
		credits_text.position.y - 3100,
		12
	).set_trans(Tween.TRANS_LINEAR)
	
	await move_credits.finished
	menu_button.pressed.connect(mainmenu_button_pressed)
	
	var manu_fade_in := create_tween()
	manu_fade_in.tween_interval(5)
	manu_fade_in.tween_property(menu_button, "modulate:a", 1.0, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
func mainmenu_button_pressed():
	SceneManager.change_to_packed_with_transition(Global.settings.main_menu_scene, Global.settings.reverse_carpet_transition)
	
	
	
