extends Node2D

@export var final_voice : AudioStream
@export var final_scene : PackedScene
func _ready() -> void:
	await Utils.wait(1.0)
	SoundManager.play_sound(final_voice)
	await Utils.wait(final_voice.get_length())
	
	await Utils.wait(1.0)
	
	SceneManager.change_to_packed_with_default_transition(final_scene)
