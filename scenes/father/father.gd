extends Node2D

@export var final_voice : AudioStream

func _ready() -> void:
	await Utils.wait(1.0)
	SoundManager.play_sound(final_voice)
	await Utils.wait(final_voice.get_length())
	
	await Utils.wait(1.0)
	
	## TODO: Trigger end
